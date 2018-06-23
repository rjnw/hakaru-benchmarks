from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time

# K = length(topic_prior)
# D = size(z)
# N = map number-of-word documents
# w[d] = words in document d

# from file
# at line n in docs file = same line word in words file


augur_nb = '''(K : Int, D1 : Int, D2 : Int, N1 : Int, N2 : Int, topic_prior : Vec Real, word_prior : Vec Real, doc1 : Vec Int, doc2 : Vec Int) => {
 param theta ~ Dirichlet(topic_prior);
 param phi[k] ~ Dirichlet(word_prior)
     for k <- 0 until K ;
 data z1[d] ~ Categorical(theta)
     for d <- 0 until D1 ;
 param z2[d] ~ Categorical(theta)
     for d <- 0 until D2 ;
 data w1[n] ~ Categorical(phi[z1[doc1[n]]])
     for n <- 0 until N1;
 data w2[n] ~ Categorical(phi[z2[doc2[n]]])
     for n <- 0 until N2;
}
'''
# z1 topics for training documents w1 words for z1
# z2 topics for heldout documents


augur_nb_old = '''(K : Int, D : Int, N : Int, topic_prior : Vec Real, word_prior : Vec Real, doc : Vec Int) => {
  param theta ~ Dirichlet(topic_prior);
  param phi[k] ~ Dirichlet(word_prior)
      for k <- 0 until K ;
  param z[d] ~ Categorical(theta)
      for d <- 0 until D ;
  data w[n] ~ Categorical(phi[z[doc[n]]])
      for n <- 0 until N;
}
'''
  # data w[d, n] ~ Categorical(phi[z[d]])
  #     for d <- 0 until D, n <- 0 until N[d] ;

sched1 = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z2]'
sched2 = 'DiscGibbs [z2]'

def holdout(i):
    return (i%50 == 0)

def split_training(ndocs, nwords, ntopics, topics, docs, words):
    z1_map = {}
    z1n=0
    z2_map = {}
    z2n=0
    for d, t in enumerate(topics):
        if holdout(d):
            z2_map[d] = (z2n, t)
            z2n+=1
        else:
            z1_map[d] = (z1n, t)
            z1n+=1
    z1=[val for idx,val in enumerate(topics) if not holdout(idx)]
    w1=[word for doc,word in zip(docs, words) if not holdout(doc)]
    d1=[z1_map[doc][0] for doc,word in zip(docs, words) if not holdout(doc)]
    z2=[val for idx,val in enumerate(topics) if  holdout(idx)]
    w2=[word for doc,word in zip(docs, words) if holdout(doc)]
    d2=[z2_map[doc][0] for doc,word in zip(docs, words) if holdout(doc)]
    return ((z1,w1,d1), (z2,w2,d2))

def log_snapshot(tim, num_samples, z,out):
    out.write("%.3f" % tim)
    out.write(' ')
    out.write(str(num_samples))
    out.write(' ')
    out.write('['+' '.join([str(n) for n in z]) + ']')
    out.write('\t')

def run_nb(words, docs, topics, outf):

    num_docs = 1+docs[-1]
    num_words=1+max(words)
    num_topics=1+max(topics)
    out=open(outf+str(num_topics)+'-'+str(num_docs), 'w')

    topic_prior = np.full(num_topics, 1.0)
    word_prior = np.full(num_words, 1.0)

    ((z1, w1, doc1), (z2,w2,doc2)) = split_training(num_docs, num_words, num_topics, topics, docs, words)
    D1=len(z1)
    D2=num_docs - D1
    N1=len(w1)
    N2=len(w2)
    with AugurInfer('config.yml', augur_nb) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched2)
        init_time = time.clock()
        infer_obj.compile(num_topics, D1, D2, N1, N2, topic_prior, word_prior, np.array(doc1), np.array(doc2))(np.array(z1), np.array(w1), np.array(w2))
        compile_time=time.clock()-init_time
        num_samples = 0
        print 'compile-time: ', compile_time
        tim0=time.clock()
        while num_samples <= 50 or tim < 1:
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z2'][0]
            tim = time.clock() - tim0
            print 'time at sweep: ', num_samples, tim
            log_snapshot(tim, num_samples, z,out)
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
    doc = []
    for (d,w) in zip(docs, words):
        if d == ci:
            doc.append(w)
            ci=d
        else:
            ci=d
            ndoc=np.array(doc, dtype=np.int32)
            arr.append(ndoc)
            doc=[w]
    return np.array(arr, dtype=np.int32)

if __name__ == '__main__':
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    topics=loadNewsFile(topics_file)
    print 'loaded news...'
    run_nb(words, docs, topics, '../../output/NaiveBayesGibbs/augur/')
