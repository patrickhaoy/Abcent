from google.cloud import speech_v1
from google.cloud.speech_v1 import enums
from google.cloud import speech_v1p1beta1
from google.protobuf.json_format import MessageToJson
from flask import jsonify
import logging
import io
import re, math
from collections import Counter
import json

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

    return cosine, incorrect_words, original_distinct_words

def sample_recognize_word_level_uri(request):
    storage_uri = request.args.get('uri', '')
    original_text = request.args.get('original', '')
    if not storage_uri:
        return jsonify({'error': 'uri parameter as input is needed'})

    if not original_text:
        return jsonify({'error': 'original text as input is needed'})
    logging.info('input: {}'.format(storage_uri))
    
    client = speech_v1p1beta1.SpeechClient.from_service_account_file("accentreducer-6e419ce43996.json")
    enable_word_confidence = True

    # The language of the supplied audio
    language_code = "en-US"
    encoding = enums.RecognitionConfig.AudioEncoding.LINEAR16
    config = {
        "enable_word_confidence": enable_word_confidence,
        "encoding": "LINEAR16",
        "sample_rate_hertz": 44100,
        "max_alternatives": 3,
        "language_code": language_code,
        "audio_channel_count": 2,
        #"encoding": encoding,
    }
    audio = {"uri": storage_uri}

    response = client.recognize(config, audio)
    # The first result includes confidence levels per word
    result = response.results[0]
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    transcript = alternative.transcript
    words_confidences = alternative.words

    cosine, incorrect_words, original_vocab = compare(transcript, original_text)
    
    unsure_words = []
    for i in range(0, len(words_confidences)):
        if words_confidences[i].confidence < 0.75 and words_confidences[i].word in original_vocab:
            unsure_words.append(words_confidences[i].word)

    data = {}
    data['cosine'] = cosine
    data['transcript'] = transcript
    data['original'] = original_text
    data['incorrect_words'] = incorrect_words
    data['unsure_words'] = unsure_words
    json_data = json.dumps(data)

    # alternative_json = MessageToJson(alternative)
    # return response_json
    return json_data
