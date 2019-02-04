from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time
import sys

augur_lda = '''
(ntopics : Int, ndocs : Int, w_shape : Vec Int, topics_prior : Vec Real, words_prior : Vec Real) => {
  param theta[d] ~ Dirichlet(topics_prior)
      for d <- 0 until ndocs ;
  param phi[k] ~ Dirichlet(words_prior)
      for k <- 0 until ntopics ;
  param z[d, n] ~ Categorical(theta[d])
      for d <- 0 until ndocs, n <- 0 until w_shape[d] ;
  data w[d, n] ~ Categorical(phi[z[d, n]])
      for d <- 0 until ndocs, n <- 0 until w_shape[d] ;
}
'''

sched = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z]'
def run_lda(words, docs, num_topics, out, num_samples):
    def log_snapshot(tim, num_samples, z):
        print('logging snapshot')
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('[')
        for za in z:
            for zi in za:
                out.write(' '+str(zi))
        out.write(' ]')
        out.write('\t')

    w = doc_word(docs, words)
    num_words=max(words)+1


    topic_prior = np.array([1.0]*num_topics)
    word_prior = np.array([1.0]*num_words)

    with AugurInfer('config.yml', augur_lda) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched)

        w_shape = np.array([x for x in map(len, w)], dtype=np.int32)
        init_time = time.clock()
        infer_obj.compile(num_topics, len(w_shape), w_shape, topic_prior, word_prior)(w)
        samples = 0
        tim = time.clock()
        while (time.clock() - tim) < 1000:
            print "getting sample: ", samples
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            print "got a sample in time: ", time.clock() - tim
            log_snapshot((time.clock() - tim), samples, z)
            samples += 1
        out.write('\n')

def loadNewsFile(fname) :
    with open(fname) as inp:
        raw=inp.readlines()
    return map(int, raw)

def doc_word(docs, words):
    arr = []
    acc = []
    curr_doc = docs[0]
    for doc, word in zip(docs, words):
        if doc is curr_doc:
            acc += [word]
        else:
            curr_doc = doc
            arr += [np.array(acc, dtype=np.int32)]
            acc = [word]
    arr+= [np.array(acc, dtype=np.int32)]
    return np.array(arr)

if __name__ == '__main__':
    [ns, input_folder, output_dir, num_topics, num_trials] = sys.argv
    words_file = input_folder + "words"
    docs_file = input_folder + "docs"
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    print 'loaded news...'
    with open(output_dir + '/augur-'+num_topics , 'w') as out:
        for i in range(int(num_trials)):
            run_lda(words, docs, int(num_topics), out, 0)
