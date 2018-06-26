from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time


augur_lda = '''(K : Int, D : Int, N : Vec Int, alpha : Vec Real, beta : Vec Real) => {
  param theta[d] ~ Dirichlet(alpha)
      for d <- 0 until D ;
  param phi[k] ~ Dirichlet(beta)
      for k <- 0 until K ;
  param z[d, n] ~ Categorical(theta[d])
      for d <- 0 until D, n <- 0 until N[d] ;
  data w[d, n] ~ Categorical(phi[z[d, n]])
      for d <- 0 until D, n <- 0 until N[d] ;
}
'''

sched1 = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z]'

def run_lda(ntopics, ndocs, topics, w, out):
    def log_snapshot(tim, num_samples, z):
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('['+' '.join([str(n) for n in z]) + ']')
        out.write('\t')

    num_words=59967
    num_topics=20

    topic_prior = np.array([1.0]*num_topics)
    word_prior = np.array([1.0]*num_words)

    with AugurInfer('config.yml', augur_lda) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched1)

        init_time = time.clock()
        w_shape = np.array([x for x in map(len, w)])

        print num_topics, ndocs, w_shape, topic_prior, word_prior, w
        error()
        infer_obj.compile(num_topics, ndocs, w_shape, topic_prior, word_prior)(w)
        num_samples = 1
        tim = 0
        while num_samples <= 10 or tim < 1:
            tim = time.clock() - init_time
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            log_snapshot(tim, num_samples, z)
            num_samples += 1
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
    ci = 0
    doc = np.array([])
    for (d,w) in zip(docs, words):
        if d == ci:
            doc=np.append(doc, w)
            ci=d
        else:
            ci=d
            arr.append(doc)
            doc=np.array([w])
    return np.array(arr)

if __name__ == '__main__':
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    topics=loadNewsFile(topics_file)
    w = doc_word(docs, words)
    print 'loaded news...'
    ntopics, ndocs = 20,19997
    with open('../../output/NaiveBayesGibbs/augur/news', 'w') as out:
        run_lda(ntopics, ndocs, topics, w, out)
