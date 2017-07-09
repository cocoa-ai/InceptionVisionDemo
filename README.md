# Inception Vision Demo

A Demo application using `Vision` and `CoreML` frameworks to detect the
dominant objects presented in a live video feed from a set of 1000 categories
such as trees, animals, food, vehicles, people, and more.

<div align="center">
<img src="https://github.com/cocoa-ai/InceptionVisionDemo/blob/master/Screenshot.png" alt="InceptionVisionDemo" width="300" height="534" />
</div>

## Model

This demo uses "Inception v3" [CoreML model](https://developer.apple.com/machine-learning/).

## Requirements

- Xcode 9
- iOS 11

## Installation

```sh
git clone https://github.com/cocoa-ai/InceptionVisionDemo.git
cd InceptionVisionDemo
pod install
open Inception.xcworkspace/
```

Download the CoreMl model from https://developer.apple.com/machine-learning/
and add the file to "Resources" folder in the project's directory.

Build the project and run it on a simulator or a device with iOS 11.

## Author

Vadym Markov, markov.vadym@gmail.com

## References
- [Caffe Model Zoo](https://github.com/caffe2/caffe2/wiki/Model-Zoo)
- [Apple Machine Learning](https://developer.apple.com/machine-learning/)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [CoreML Framework](https://developer.apple.com/documentation/coreml)
- [coremltools](https://pypi.python.org/pypi/coremltools)
