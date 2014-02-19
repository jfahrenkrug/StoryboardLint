StoryboardLint
==============

A lint tool for UIStoryboard to find wrong classes and wrong storyboard/segue/reuse identifiers.

Background
----------
In iOS development, UIStoryboards are a pain to use [for many reasons](http://stackoverflow.com/questions/9404471/when-to-use-storyboard-and-when-to-use-xibs/19457257#19457257).
Two big reasons are:
 - You can only use string literals as identifiers for view controllers and segues in your Storyboards. You need those same string literals again in your source code when referencing anything in your Storyboard: So you have your IDs in two or more places and no way to know if the IDs you use in your code actually exist in your Storyboard.
 - You have no way of knowing whether your Storyboard references classes in your source code that don't exist (anymore).

Fear Not!
---------
With StoryboardLint, you can finally make sure that your code and your Storyboards are in sync (at least to a certain degree). StoryboardLint does the following things:

 - Makes sure your `UITableViewCell` and `UICollectionViewCell` reuse identifiers are named according to StoryboardLint's naming convention.
 - Makes sure your Storyboard and Segue identifiers are named according to StoryboardLint's naming convention.
 - Makes sure that all custom classes that are references from your Storyboard actually exist is your code.
 - Makes sure that all string literals in your code that reference reuse identifiers, Storyboard identifiers and Segue identifiers (according to the naming convention) actually exist in your Storyboard(s).
 - Produces output that is parsable by Xcode so you can easily plug StoryboardLint into your build process:

**Warnings right in your source code:**

![Xcode Warnings](http://i.imgur.com/G24DJhf.png)

**Warnings about bugs in your Storyboard:**

![Xcode Warnings](http://i.imgur.com/rfInSBE.png)
 
Naming Convention
-----------------
In order for StoryboardLint to find the string literals in your code that contain reuse/Storyboard/Segue identifiers, you need to prefix them as follows:

 - Reuse Identifiers start with `ruid_`. Example: `ruid_ProductTableViewCell`.
 - Storyboard Identifiers start with `sb_`. Example: `sb_ProductsViewController`.
 - Segue Identifiers start with `seg_`. Example: `seg_ProductDetailsSegue`.
 
This should not be too much work and it will be worth it. Ideally you already have string constants for these things in your code, so that you only have to edit two places: your string constant in code and the respective value in your Storyboard.

Installation
------------
Just install the Ruby Gem:

    sudo gem install storyboardlint
    
In your Xcode Project, simply add a "Run Script" build phase in order to run StoryboardLint every time you build:

1. Go to your project and select your project's target in the "Targets" section.
2. Go to "Build Phases"
3. Select from the Menu "Editor -> Add Build Phase -> Add Run Script Build Phase"
4. Paste this command into the Run Script section: `storyboardlint "$SRCROOT"`
5. That's it!



