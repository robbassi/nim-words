# Reads a file and construct a 2 word prefix markov, which is then used to generate anew sentence.

import random, tables, strutils

# contains a table for prefix to suffix mapping, and
# a sequence of the unique keys for random sampling
type Chain = object
  table*: TableRef[string, seq[string]]
  keys*: seq[string]

# iterate over all words in a file
iterator words(filename: string): string =
  var
    file = open(filename)
    word = ""
    c: char
  while not endOfFile file:
    c = readChar(file)
    case c
    of ' ', '\t', '.', ',', ';':
      yield word
      word = ""
    of 'a'..'z', 'A'..'Z', '0'..'9', '!':
      word.add c
    of '\l': discard
    else: discard
  yield word

# build a chain from a file
proc buildChain(filename: string): Chain =
  var
    chain = Chain(table: newTable[string, seq[string]](), keys: @[])
    prefix1, prefix2 = ""
  for word in words(filename):
    let key = prefix1 & ' ' & prefix2
    if not chain.table.hasKey key:
      chain.table[key] = @[]
      chain.keys.add key
    chain.table.mget(key).add(word)
    prefix1 = prefix2
    prefix2 = word
  return chain

# given a chain, randomly select a key, and start appending key + suffix to a string
proc generateSentence(chain: Chain; maxLen: int = 100): string =
  let
    keys = chain.keys
    keyLen = keys.len
    idx = randomInt keyLen
  var
    len = 0
    key = keys[idx]
    sentence = key.strip
  while (chain.table.hasKey key) and (len < maxLen):
    let
      suffixes = chain.table[key]
      suffixesLen = suffixes.len
      suffixIdx = randomInt suffixesLen
      suffix = suffixes[suffixIdx].strip
      newKey = key.split(' ')[1] & ' ' & suffix
    if suffix != "":
      sentence.add ' ' & suffix
    key = newKey
    len += 3
  return sentence

# create a chain from a txt file
var chain = buildChain("source.txt")

# generate a sentence (max 250 words)
echo generateSentence(chain, maxLen = 250)
