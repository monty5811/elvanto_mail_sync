var path = require("path");
var webpack = require('webpack');

module.exports = {
  context: __dirname,

  entry: {
    App: './elm/App',
  },

  output: {
    path: path.resolve('../elvanto_sync/static/js/'),
    filename: "[name].js",
  },

  resolve: {
    extensions: ['.js'],
  },

  plugins: [
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false
    }),
  ],

  module: {
    loaders: [
      {
        test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: 'elm-webpack'
      },
    ],
  },

  watchOptions: {
    poll: 500
  }
}
