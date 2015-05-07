# read a file and construct a markov chain for word probabilities
import random, tables, strutils

type Chain = object
  table*: TableRef[string, seq[string]]
  keys*: seq[string]

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

proc generateSentence(chain: Chain; maxLen: int = 100): string =
  let
    keys = chain.keys
    keyLen = keys.len
    idx = randomInt keyLen
  var
    len = 0
    key = keys[idx]
    sentence = key

  while (chain.table.hasKey key) and (len < maxLen):
    let
      suffixes = chain.table[key]
      suffixesLen = suffixes.len
      suffixIdx = randomInt suffixesLen
      suffix = suffixes[suffixIdx]
      newKey = key.split(' ')[1] & ' ' & suffix
    sentence.add ' ' & suffix
    key = newKey
    len += 3
  return sentence

var
  chain = buildChain("source.txt")

echo generateSentence(chain, maxLen = 250)
