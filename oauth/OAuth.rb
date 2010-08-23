#!/usr/bin/env ruby

###########################################
# GDD 2010 fall DevQuiz Question2-2 OAuth #
# TAC <tac@tac42.net>                     #
###########################################

require 'rubygems'
require 'oauth'

CONSUMER_KEY = 'consumer key'
CONSUMER_SECRET = 'cousumer secret'
SITE = 'http://gdd-2010-quiz-japan.appspot.com/oauth/'+CONSUMER_KEY

p OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET).request(:post, SITE, nil,{:realm => :devquiz},{ :hello => :world})
