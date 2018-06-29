from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time


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
def run_lda(words, docs, topics, out):
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
        print('done loging')

    w = doc_word(docs, words)
    num_words=max(words)+1
    num_topics=max(topics)+1

    topic_prior = np.array([1.0]*num_topics)
    word_prior = np.array([1.0]*num_words)

    with AugurInfer('config.yml', augur_lda) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched)

        init_time = time.clock()
        w_shape = np.array([x for x in map(len, w)], dtype=np.int32)

        infer_obj.compile(num_topics, len(w_shape), w_shape, topic_prior, word_prior)(w)
        num_samples = 5
        tim = 0
        while num_samples <= 500:
            print "getting sample: ", num_samples
            start_time=time.clock()
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            tim = time.clock() - start_time
            print "got a sample in time: ", tim
            log_snapshot(tim, num_samples, z)
            num_samples += 5
        out.write('\n')

news_dir = '../../input/news/'
words_file=news_dir+'words'
docs_file=news_dir+'docs'
topics_file=news_dir+'topics'

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
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    topics=loadNewsFile(topics_file)
    print 'loaded news...'
    with open('../../output/LdaGibbs/augur/news-20-19997', 'w') as out:
        run_lda(words, docs, topics, out)
