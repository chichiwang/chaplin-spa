# EverFi: Financial Literacy

## Documentation
* [Getting Started](#getting-started)
* [Using Scaffolt](#using-scaffolt)
* [Coding Style Conventions](#coding-style-conventions)

## Brunch with Chaplin
![bwc-logo](http://brunch.io/images/svg/brunch.svg)

This is HTML5 application, built with
[Brunch](http://brunch.io) and [Chaplin](http://chaplinjs.org).

## Getting started
* Install (if you don't have them):
    * [Node.js](http://nodejs.org): `brew install node` on OS X
    * [Brunch](http://brunch.io): `npm install -g brunch`
    * [Bower](http://bower.io): `npm install -g bower`
    * [Scaffolt](https://github.com/paulmillr/scaffolt): `npm install -g scaffolt`

## Project Installation
* Install:
    * Clone this repo
    * Run `npm install` in the root directory to install all [Brunch](http://brunch.io) packages
    * Run `bower install` in the root directory to install all project dependencies
* Workflow:
    * `brunch watch --server` — watches the project with continuous rebuild. This will also launch HTTP server with [pushState](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history).
    * `brunch watch -s -p xxxx` watches the project and launches the HTTP server on port XXXX.
    * `brunch build --production` — builds minified project for production
    * `public/` dir is fully auto-generated and served by HTTP server.  Write your code in `app/` dir.
    * Place static files you want to be copied from `app/assets/` to `public/`.
    * [Brunch site](http://brunch.io), [Chaplin site](http://chaplinjs.org)

## Using Scaffolt
[Scaffolt](https://github.com/paulmillr/scaffolt) is a command-line scaffolding tool built to help you generate skeleton [Chaplin](http://chaplinjs.org) objects in your project.

In our project we can use it as an easy way to generate the skeleton views, controllers, models, templates and stylesheets we need.

Usage:
```shell
$ scaffolt style photos-main -p app/views/photos/styles
$ scaffolt template photos -p app/views/photos/templates
$ scaffolt view photos -p app/views/photos
$ scaffolt controller photos -p app/controllers
$ scaffolt model photo -p app/models/photos
```

This will create a `photos-main.styl` file in the directory `app/views/photos/styles`, a `photos.hbs` file in the directory `app/views/photos/templates`, etc.

Refer to the [Scaffolt README](https://github.com/paulmillr/scaffolt/blob/master/README.md) for more information

# Coding Style Conventions
The development team has drafted up the following style conventions for this project.

* HTML:
    * Element classes will be all lower-case and use underscores to separate words (ex: `class="main_page"`).
    * Element ids will be capital-case and use underscores to separate words (ex: `id="Page_Container"`).
    * Reserve use of element ids to page level root elements and component root elements to avoid polluting the app with too many ids.
* Stylesheets:
    * Variables will be defined by a preceding dollar sign. They will be lowercase with underscores to separte words (ex: `$my_color = red`).
    * Mixins will be defined by a preceding `$mx_`. They will be lowercase with underscores to separate words (ex: `$mx_my_mixin(values)`).
* Javascript:
    * Class objects will be capital-cased (ex: `class MyClass`).
    * Variable, function, and class Instance names will be camel-cased (ex: `myInstance = new MyClass`).
* Files:
    * File names will be lower-case and use hyphens to separate words (ex: `home-controller.coffee`).