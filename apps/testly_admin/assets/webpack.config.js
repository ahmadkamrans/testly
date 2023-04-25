const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const Webpack = require("webpack");

module.exports = (env, options) => ({
  mode: process.env.NODE_ENV === "production" ? "production" : "development",
  devtool:
    process.env.NODE_ENV === "production" ? "source-map" : "inline-source-map",
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      // Css-loader & sass-loader
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: "css-loader", options: {
              sourceMap: true, importLoaders: true,
            }
          },
          {
            loader: "postcss-loader", options: {
              sourceMap: 'inline'
            }
          },
          {
            loader: "sass-loader", options: {
              sourceMap: true
            }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader?sourceMap']
      },
      {
        test: /\.(jpe?g|png|gif|woff|woff2|eot|ttf|svg)(\?[a-z0-9=.]+)?$/,
        loader: 'url-loader?limit=100000'
      },
      // Expose loader
      {
        test: require.resolve("jquery"),
        use: [
          {
            loader: "expose-loader",
            options: "jQuery"
          },
          {
            loader: "expose-loader",
            options: "$"
          }
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
    new Webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.$": "jquery",
      "window.jQuery": "jquery",
      Popper: ["popper.js", "default"]
    }),
  ]
});
