from google.cloud import speech_v1
from google.cloud.speech_v1 import enums
from google.cloud import speech_v1p1beta1
import io
import subprocess
from pydub import AudioSegment

def sample_recognize_local(local_file_path):
    """
    Transcribe a short audio file using synchronous speech recognition

    Args:
      local_file_path Path to local audio file, e.g. /path/audio.wav
    """

    print("running..")

    client = speech_v1.SpeechClient.from_service_account_file("accentreducer-ab3254b75d97.json")

    # local_file_path = 'resources/brooklyn_bridge.raw'

    # The language of the supplied audio
    language_code = "en-US"

    # Sample rate in Hertz of the audio data sent
    #sample_rate_hertz = 44100

    # Encoding of audio data sent. This sample sets this explicitly.
    # This field is optional for FLAC and WAV audio formats.
    encoding = enums.RecognitionConfig.AudioEncoding.LINEAR16
    config = {
        "language_code": language_code,
        #"sample_rate_hertz": sample_rate_hertz,
        #"audio_channel_count": 2,
        "encoding": encoding,
    }
    with io.open(local_file_path, "rb") as f:
        content = f.read()
    audio = {"content": content}

    response = client.recognize(config, audio)
    for result in response.results:
        # First alternative is the most probable result
        alternative = result.alternatives[0]
        print(u"Transcript: {}".format(alternative.transcript))

# sample_recognize("test/birch-canoe.wav")
# print("hi")
def sample_recognize_word_level(local_file_path):
    """
    Print confidence level for individual words in a transcription of a short audio
    file.

    Args:
      local_file_path Path to local audio file, e.g. /path/audio.wav
    """

    client = speech_v1p1beta1.SpeechClient.from_service_account_file("accentreducer-6e419ce43996.json")

    # local_file_path = 'resources/brooklyn_bridge.flac'

    # When enabled, the first result returned by the API will include a list
    # of words and the confidence level for each of those words.
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
    with io.open(local_file_path, "rb") as f:
        content = f.read()

    # subprocess.call(['ffmpeg', '-f', 's16le', '-ar', '44.1k', '-ac', '2', '-i', local_file_path, 'output.wav'])
    
    # with io.open('output.wav', "rb") as f:
    #     content = f.read()
    
    audio = {"content": content}

    response = client.recognize(config, audio)
    print("hi")
    print(response)
    # The first result includes confidence levels per word
    result = response.results[0]
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    transcript = alternative.transcript
    words_confidences = alternative.words
    # print(u"Transcript: {}".format(alternative.transcript))
    # # Print the confidence level of each word
    # for word in alternative.words:
    #     print(u"Word: {}".format(word.word))
    #     print(u"Confidence: {}".format(word.confidence))
    #print(response)
    print(words_confidences)

def sample_recognize_uri(storage_uri):
    """
    Transcribe short audio file from Cloud Storage using synchronous speech
    recognition

    Args:
      storage_uri URI for audio file in Cloud Storage, e.g. gs://[BUCKET]/[FILE]
    """

    client = speech_v1.SpeechClient.from_service_account_file("accentreducer-6e419ce43996.json")

    # storage_uri = 'gs://cloud-samples-data/speech/brooklyn_bridge.raw'

    # Sample rate in Hertz of the audio data sent
    sample_rate_hertz = 16000

    # The language of the supplied audio
    language_code = "en-US"

    # Encoding of audio data sent. This sample sets this explicitly.
    # This field is optional for FLAC and WAV audio formats.
    encoding = enums.RecognitionConfig.AudioEncoding.LINEAR16
    config = {
        "sample_rate_hertz": sample_rate_hertz,
        "language_code": language_code
    }
    audio = {"uri": storage_uri}

    response = client.recognize(config, audio)
    for result in response.results:
        # First alternative is the most probable result
        alternative = result.alternatives[0]
        print(u"Transcript: {}".format(alternative.transcript))

def sample_recognize_word_level_uri(storage_uri):
    client = speech_v1p1beta1.SpeechClient.from_service_account_file("accentreducer-6e419ce43996.json")
    enable_word_confidence = True

    # The language of the supplied audio
    language_code = "en-US"
    config = {
        "enable_word_confidence": enable_word_confidence,
        "encoding": "LINEAR16",
        "sample_rate_hertz": 44100,
        "max_alternatives": 3,
        "language_code": language_code,
        "audio_channel_count": 2
    }
    audio = {"uri": storage_uri}

    response = client.recognize(config, audio)
    # The first result includes confidence levels per word
    result = response.results[0]
    # First alternative is the most probable result
    alternative = result.alternatives[0]
    print(u"Transcript: {}".format(alternative.transcript))
    # Print the confidence level of each word
    for word in alternative.words:
        print(u"Word: {}".format(word.word))
        print(u"Confidence: {}".format(word.confidence))


#sample_recognize_word_level_uri("gs://accent_reducer_audio_files/friends.wav")
sample_recognize_word_level("test/-LqvgaVcZGashinopljleT.wav")
