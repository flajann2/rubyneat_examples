#!/bin/bash

bundle config --delete rubyneat
bundle config --delete rubyneat_dashboard

bundle config --delete global.rubyneat
bundle config --delete global.rubyneat_dashboard

bundle config --delete local.rubyneat
bundle config --delete local.rubyneat_dashboard

bundle config local.rubyneat ~/development/ruby_proj/rubyneat
bundle config local.rubyneat_dashboard ~/development/ruby_proj/rubyneat_dashboard
