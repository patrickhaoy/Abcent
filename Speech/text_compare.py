import re, math
from collections import Counter

WORD = re.compile(r'\w+')

def get_cosine(vec1, vec2):
     intersection = set(vec1.keys()) & set(vec2.keys())
     numerator = sum([vec1[x] * vec2[x] for x in intersection])

     sum1 = sum([vec1[x]**2 for x in vec1.keys()])
     sum2 = sum([vec2[x]**2 for x in vec2.keys()])
     denominator = math.sqrt(sum1) * math.sqrt(sum2)

     if not denominator:
        return 0.0
     else:
        return float(numerator) / denominator

def text_to_vector(text):
     words = WORD.findall(text)
     return Counter(words)

def compare(transcript, original):
    transcript_vector = text_to_vector(transcript)
    original_vector = text_to_vector(original)
    cosine = get_cosine(transcript_vector, original_vector)
    print('Cosine:', cosine)

    transcript_distinct_words = [key for key, _ in transcript_vector.most_common()]
    original_distinct_words = [key for key, _ in original_vector.most_common()]

    incorrect_words = []

    for word in original_distinct_words:
        if word not in transcript_distinct_words:
            incorrect_words.append(word)

    print(incorrect_words)

text1 = "Toys R Us have a conversation practice your Chinese morning"
text2 = "you can't talk with us have a conversation sometimes so you can practice your Chinese more than "
compare(text1, text2)