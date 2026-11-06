# CurrencyExchange

A currency conversion iOS application built with Swift, UIKit, and MVVM.

## Overview

Currency Exchange is an iOS application that allows users to convert amounts between different currencies using exchange rates retrieved from an external API.

## Tech Stack

* Language: Swift
* UI Framework: UIKit
* Layout: Auto Layout
* Architecture: MVVM (Model-View-ViewModel)
* Networking: URLSession

## Features

* Currency conversion using exchange rates.

* Source and target currency selection.

* Currency swapping.

* Bidirectional amount input.

* Exchange rate fetching via REST API.

* In-memory caching and bundled fallback data.

* Input validation for decimal amounts.

* Loading and error states.

## Architecture

MVVM separates business logic from UIKit components and makes currency conversion behaviour easier to unit test. For a small application, this is a practical alternative to more complex architectures such as VIPER.

* Model — represents the application's data.

* View — displays the user interface and handles user interactions.

* ViewModel — manages presentation logic and provides data for the View.

This separation helps keep the code organized and makes individual components easier to maintain.

## Requirements

* macOS with a compatible version of Xcode
* Swift version supported by the project
* iOS 18.6

## Getting Started

#### 1. Clone the repository

* git clone https://github.com/Leibnz/CurrencyExchange.git

#### 2. Navigate to the project directory

#### 3. Open the project

* Open the CurrencyExchange.xcodeproj file in Xcode.

#### 4. Run the application
