from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time


augur_lda = '''
(ndocs : Int, ntopics : Int, nwords : Int, topics_prior : Vec Real, word_prior : Vec Real, doc : Vec Int) => {
  param theta[d] ~ Dirichlet(topics_prior)
      for d <- 0 until ndocs ;
  param phi[k] ~ Dirichlet(word_prior)
      for k <- 0 until ntopics ;
  param z[d] ~ Categorical(theta[doc[d]])
      for d <- 0 until nwords ;
  data w[d] ~ Categorical(phi[z[d]])
      for d <- 0 until nwords ;
}
'''

sched1 = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z]'

def run_lda(topics, doc, words, out):
    def log_snapshot(tim, num_samples, z):
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('['+' '.join([str(n) for n in z]) + ']')
        out.write('\t')

    num_words=len(words)
    num_topics=20
    num_docs = max(topics)+1


    topic_prior = np.array([1.0]*num_topics)
    word_prior = np.array([1.0]*num_words)

    with AugurInfer('config.yml', augur_lda) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched1)

        init_time = time.clock()

        # print num_topics, ndocs, w_shape, topic_prior, word_prior, w
        # error()
        infer_obj.compile(num_docs, num_topics, num_words, topic_prior, word_prior, np.array(doc, dtype=np.int32))\
            (np.array(words, dtype=np.int32))
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
    print 'loaded news...'
    with open('../../output/NaiveBayesGibbs/augur/news', 'w') as out:
        run_lda(topics, docs, words, out)
