from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time
import sys
# K = length(topic_prior)
# D = size(z)
# N = map number-of-word documents
# w[d] = words in document d

# from file
# at line n in docs file = same line word in words file


augur_nb_2d_partially_supervised = '''(K : Int, D1 : Int, D2 : Int, topic_hyper : Vec Real, word_hyper : Vec Real, doc1_length : Vec Int, doc2_length : Vec Int) => {
  param theta ~ Dirichlet(topic_hyper);
  param phi[k] ~ Dirichlet(word_hyper)
      for k <- 0 until K ;
  data z1[d] ~ Categorical(theta)
      for d <- 0 until D1 ;
  param z2[d] ~ Categorical(theta)
      for d <- 0 until D2 ;
  data w1[d, n] ~ Categorical(phi[z1[d]])
      for d <- 0 until D1, n <- 0 until doc1_length[d];
  data w2[d, n] ~ Categorical(phi[z2[d]])
      for d <- 0 until D2, n <- 0 until doc2_length[d];
}
'''
# z1 topics for training documents w1 words for z1
# z2 topics for heldout documents

sched = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z2]'


def npi32(arr):
    return np.array(arr, dtype=np.int32)

def doc_word(topics, docs, words):
    print len(docs), len(words)
    arr = []
    acc = []
    curr_doc = docs[0]
    doc_id = 0
    for doc, word in zip(docs, words):
        if doc == curr_doc:
            acc += [word]
        else:
            curr_doc = doc
            doc_id+=1
            while doc_id != curr_doc:
                assert doc_id <=  curr_doc
                arr+=[[]]
                doc_id+=1
            arr += [acc]
            assert len(arr) == doc_id
            acc = [word]
    arr+= [acc]
    assert len(topics) == len(arr)
    return arr

def run_nb(words, docs, topics, out, total_sweeps, total_time, holdout_modulo):

    def holdout(i):
        return (i%holdout_modulo == 0)

    num_docs = len(topics)
    num_words=1+max(words)
    num_topics=1+max(topics)
    dw = doc_word(topics, docs, words)
    z1_map = []
    z1_tmap = []
    z1_dmap = {}
    z1n=0
    z2_map = []
    z2n=0
    for d, t in enumerate(topics):
        if holdout(d):
            z2_map += [(z2n, d)]
            z2n+=1
        else:
            z1_map += [(z1n, d)]
            z1_tmap += [t]
            z1_dmap[d] = z1n
            z1n+=1
    D1= len(z1_map)
    D2= len(z2_map)
    assert D1+D2 == len(dw)
    w1 = np.array([npi32(dw[oz]) for (z1i, oz) in z1_map])
    w2 = np.array([npi32(dw[oz]) for (z2i, oz) in z2_map])

    (z1, D1, D2, w1, w2) = (npi32(z1_tmap), D1, D2, w1, w2)

    def log_snapshot(tim, num_samples, z2):
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        # out.write('['+' '.join([str(n) for n in z]) + ']')
        out.write('[')
        for i in range(len(topics)):
            if (i%holdout_modulo == 0):
                out.write(str(z2[i//holdout_modulo]))
            else:
                out.write(str(topics[i]))
            out.write(' ')
        out.write(']')
        out.write('\t')

    topic_prior = np.array([1.0]*num_topics)
    word_prior = np.array([1.0]*num_words)
    doc1_length = np.array(map(len, w1), dtype=np.int32)
    doc2_length = np.array(map(len, w2), dtype=np.int32)

    with AugurInfer('config.yml', augur_nb_2d_partially_supervised) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched)
        init_time = time.clock()
        c = infer_obj.compile(num_topics, D1, D2, topic_prior, word_prior, doc1_length, doc2_length)(z1, w1,w2)

        compile_time=time.clock()-init_time
        sweeps = 0
        print 'compile-time: ', compile_time
        tim0=time.clock()
        while sweeps <= total_sweeps or (time.clock() -tim0) <= total_time:
            tim=time.clock()
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z2'][0]
            tim = time.clock() - tim
            sweeps += 1
            if sweeps%10 == 0:
                print 'sweeped: ', sweeps, 'in',  tim, 'total', time.clock()-tim0
                log_snapshot(tim, sweeps, z)

        out.write('\n')

def loadNewsFile(fname) :
    with open(fname) as inp:
        raw=inp.readlines()
    return map(int, raw)

if __name__ == '__main__':
    [ns, input_folder, output_dir, num_trials, trial_sweeps, trial_time, holdout_modulo] = sys.argv
    words_file = input_folder + "words"
    docs_file = input_folder + "docs"
    topics_file = input_folder + "topics"
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    topics=loadNewsFile(topics_file)
    print 'loaded news...'
    num_docs=len(topics)
    num_words=1+max(words)
    num_topics=1+max(topics)
    out=open(output_dir+str(num_topics)+'-'+str(num_docs)+'-'+str(holdout_modulo), 'w')
    for i in range(int(num_trials)):
        print 'running trial: ', i
        run_nb(words, docs, topics, out, int(trial_sweeps), int(trial_time), int(holdout_modulo))


# python2 nb.py ../../input/news/ ../../output/NaiveBayesGibbs/augur/ 1 10
