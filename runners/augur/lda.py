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

sched1 = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z]'

def run_lda(words, docs, topics, out):
    def log_snapshot(tim, num_samples, z):
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('['+' '.join([str(n) for n in z]) + ']')
        out.write('\t')

    w = doc_word(docs, words)
    num_words=max(words)+1
    num_topics=max(topics)+1

    topic_prior = np.array([1.0]*num_topics, dtype=np.int32)
    word_prior = np.array([1.0]*num_words, dtype=np.int32)

    with AugurInfer('config.yml', augur_lda) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched1)

        init_time = time.clock()
        w_shape = np.array([x for x in map(len, w)], dtype=np.int32)

        infer_obj.compile(num_topics, len(w_shape), w_shape, topic_prior, word_prior)(w)
        num_samples = 1
        tim = 0
        while num_samples <= 1 or tim < 1:
            tim = time.clock() - init_time
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            print "got a sample at tim: ", tim
            log_snapshot(tim, num_samples, z)
            init_time=time.clock()
            num_samples += 1
        out.write('\n')

def test_lda():
    ntopics=4
    ndocs=4
    nwords = 8
    wshape=np.array([3,4,5,6], dtype=np.int32)
    topic_prior=np.full(ntopics, 1.0)
    words_prior=np.full(nwords, 1.0)
    w = np.array([np.array([0,1,2], dtype=np.int32),
                  np.array([1,2,3,4], dtype=np.int32),
                  np.array([1,2,3,4,5], dtype=np.int32),
                  np.array([1,2,3,4,5,6], dtype=np.int32)])
    with AugurInfer('config.yml', augur_lda) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched1)
        infer_obj.compile(ntopics, ndocs, wshape, topic_prior, words_prior)(w)
        infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]


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
    ci = 0
    doc = np.array([])
    for (d,w) in zip(docs, words):
        if d == ci:
            doc=np.append(doc, w)
            ci=d
        else:
            ci=d
            arr.append(doc)
            doc=np.array([w], dtype=np.int32)
    return np.array(arr)

if __name__ == '__main__':
    # test_lda()
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    topics=loadNewsFile(topics_file)
    print 'loaded news...'
    with open('../../output/LdaGibbs/augur/news-20-19997', 'w') as out:
        run_lda(words, docs, topics, out)
