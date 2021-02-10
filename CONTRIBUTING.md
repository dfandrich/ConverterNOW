# Welcome

We invite you to join our team! Everyone is welcome to contribute code via pull requests and filing issues on GitHub. You can contribute in different ways. Do you think you are not capable to contribute? I will prove you are wrong. Let's get started!

## Translating the app

Right now the app is translated in English, Italian, Portuguese, French, Norwegian and German. If you know other languages and wants to help internationalizing take a look at the most updated instruction [here](https://github.com/ferraridamiano/ConverterNOW/issues/2). Than, if you want you can also translate the PlayStore/F-droid app page. You can find the page to translate [here](https://github.com/ferraridamiano/ConverterNOW/tree/master/fastlane/metadata/android/en-US). If you have some question please contact me via e-mail or submit a new issue. That's all, I will take care of the rest. Thank you!

## Design a new logo

If you think you are able to do a better app icon you are welcome to open a new issue with your proposal. Than I can tell you how you can merge you idea to this project. Thank you!

## Submit a PR

If you feel confident with Flutter coding, you can help me improving this app by submitting a PR. But first, let me explain you how this project is organized.

### Project structure

The project uses [provider](https://github.com/rrousselGit/provider) for state management and it helps separate the UI from the model. Right now there are two models: [AppModel.dart](https://github.com/ferraridamiano/ConverterNOW/blob/master/lib/models/AppModel.dart) contains the basic logic of the app (which page is selected, in which order, etc.) and [Conversions.dart](https://github.com/ferraridamiano/ConverterNOW/blob/master/lib/models/Conversions.dart) contains the logic of the conversion section (retrieve currencies rates from the Internet, in which order are the units of measurement, etc.). You might say: "Why don't you just make one model?", the answer is: because I plan to also make a [tools section](https://github.com/ferraridamiano/ConverterNOW/issues/6) and so it is more organized.

### Conversion algorithm

I imagined a conversion as a tree graph. Here I show part of the graph of the length conversion:

<img src="images/graph02.png" width="300">

As you can see, all units depend by other units by 1 (or more) constant. Most of the conversion between two units x and y can be done with one of these structures:

<img src="https://render.githubusercontent.com/render/math?math=%5CLarge%0Ay%20%3D%20ax%20%2B%20b">
<img src="https://render.githubusercontent.com/render/math?math=%5CLarge%0Ay%20%3D%20%5Cfrac%7Ba%7D%7Bx%7D%20%2B%20b">

The first one is the most common linear conversion (the constant helps with Fahrenheit-Celsius conversion). The second one is used in fuel conversion like <img src="https://render.githubusercontent.com/render/math?math=%5Cfrac%7Bkm%7D%7Bl%7D">  to <img src="https://render.githubusercontent.com/render/math?math=%5Cfrac%7Bl%7D%7B100km%7D">.

It can also define other types of custom conversions such between different numeral systems (binary-octal-decimal-hexadecimal).

Once a *textFormField* is selected the unit node in the graph has the property *selectedNode* equals to true (and all other *selectedNode* in every other node are marked as false). When the user changes the value of the *textFormField* the conversion propagates from the node which the user has interacted with to all other nodes. Once a node is converted the *convertedNode* property of the node is set to true.

## What if I am too lazy?

You should exit from your comfort zone and find out what it feels to submit a PR and merge it to an open source project! When you do it you feel like a little bit of this project is also yours and all the people that use this app will enjoy your contributions! But if you are too too lazy you can contribute with a small [PayPal donation](https://www.paypal.com/paypalme/DemApps) to let the developer see your interest. Thank you!

