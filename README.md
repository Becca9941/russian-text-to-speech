# Russian Text-To-Speech Using Google API

I just spent a couple hours using [Anki](https://apps.ankiweb.net/) to create a flashcard deck where each card has a Google Translate audio file attached. I used four apps in all to do this, so thought it would be better in the long run for me to just create an app to do all the things I want it to do myself.

So first things first, I need to know how to use Googles [Text To Speech API](https://codelabs.developers.google.com/codelabs/cloud-text-speech-python3/index.html?index=..%2F..index#1) so I can use the audio files in my app. This tutorial is for python, but I'll be using Ruby instead.

## Setup API Environment

First, I created an account on [Google's Cloud Console](console.cloud.google.com). Then I created a new project with a name, and saved my project ID which was provided once I had created the project.

Then I opened up the menu on the left side of the page, and clicked on the 'Dashboard' option under the 'APIs & Services' menu.

At the top of the dashboard, I clicked on the option '+ Enable APIs and Services', and searched for the text-to-speech api, which I then enabled.

In the meantime, I found a decent [tutorial for getting started with text-to-speech](https://cloud.google.com/text-to-speech/docs?hl=en_US)

## Create Audio from Text using the command-line

Create a json file called request.json. Inside that file, you will have a json file with the following properties: input, which is where you'll include the text you want google to turn into speech for you; Voice, where you can set the kind of voice who'll read out your text and in what language (provided the input is in the same language). [Voice options can be found here](https://cloud.google.com/text-to-speech/docs/voices), and finally an audioConfig property that sets the encoding for your audio, preset to MP3.

To send the request, I use curl for Mac. The original curl request looks like this:

    curl -X POST \
    -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @request.json \
    https://texttospeech.googleapis.com/v1/text:synthesize

When you run this, you get a huge response back as a json object with one property called 'audioContent'. The value it contains is huge. The next step tells you to copy the value of the audioContent propery (no quotes) and save it into a new file. This was tedious to do by hand, and there's no way I'm going to remember the curl command. So I modified the request to the following:

    curl -X POST \
    -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @request.json \
    https://texttospeech.googleapis.com/v1/text:synthesize | jq -r '.audioContent' > synthesize-output-base64.txt

The curl request stays mostly the same, except for the end, where I added on `| jq -r '.audioContent' > synthesize-output-base64.txt`.

I used [Homebrew](https://brew.sh/) to install jq, which lets you format json terminal output so it's easier to read. It also lets you access properties and their values if you want to. I used it to get the content of the 'audioContent' property `jq '.audioContent'` in it's raw state (without the string quotes) using the `-r` flag. The greater than sign pipes the property value into a new file whose name is specified at the end of the command. Whew.

I saved the curl command in a file called `curl-command.txt` which I can run by prefixing the filename with the bash command, like this:

`bash curl-command.txt`

The final step is to decode the json audioContent value into an audio file, using the following command:

`base64 synthesize-output-base64.txt --decode > synthesized-audio.mp3`

I saved this command into a file called 'convert-to-mp3.txt', which I can also run using the bash command without having to remember what it is.

## Improvements

To create a new audio file, all I need to do is edit the request.json file with the russian text I want translated, and then run 'bash curl-command.txt' and then run 'bash convert-to-mp3.txt'. I have to do those steps manually, and that's still a bit clunky to me.

I can immediately make that easier by merging the bash files into one called 'create-mp3.txt', so I'll do that.

I also don't care about the base64 audioContent file, I just care about the finished mp3 file. So I'll delete the base64 after the audio file has been created in the same 'create-mp3.txt' file. The deletion command I used was `rm -rf [filename]`

Then, I changed my default audio file name to 'audio-file' instead of 'synthesized-audio.mp3'

I showed my code to a more experienced dev, who gave me some more colol suggestions! First, is that I can change my "create-mp3.txt" to a bash file in a couple steps. First, change the extention to 'create-mp3.bash'

Then, at the top of the file, we include the following comment: `#!/bin/bash`, which says that this file is meant to be be run with bash (so we don't have to use the bash command when running it).

Finally, we enter `chmod 755 create-mp3.bash` to make the file executable. 755 sets it to read write and execute for the owner (7), read and execute for the group (5) and read and execute for the world (5). Whilst the chmod command changes the modifiers, which are the properties of the file (read, write, execute properties).

To run the file, all we need to do now is run './filename.bash'. The ./ says look in this directory for this file. The bash command handles that for you in the background.
