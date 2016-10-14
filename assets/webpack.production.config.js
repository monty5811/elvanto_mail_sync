var path = require("path");
var webpack = require('webpack');
var config = require('./webpack.base.config.js');
var ClosureCompilerPlugin = require('closure-compiler-webpack-plugin');


config.plugins = config.plugins.concat([
  new webpack.DefinePlugin({
    'process.env': {
      'NODE_ENV': JSON.stringify('production')
    }
  }),
  // minifies code
  new ClosureCompilerPlugin()
]);

module.exports = config;
