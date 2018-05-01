#!groovy

properties([
    buildDiscarder(logRotator(numToKeepStr: '3')),
])

trySlackSend(message: 'A no color ONE')

trySlackSend(color: 'danger',  message: 'A danger ONE')
trySlackSend(color: 'good',    message: 'A good ONE')
trySlackSend(color: 'grey',    message: 'A grey ONE')
trySlackSend(color: 'persian', message: 'A persian ONE')
trySlackSend(color: '#f8e348', message: 'A yellow (f8e348) ONE')
