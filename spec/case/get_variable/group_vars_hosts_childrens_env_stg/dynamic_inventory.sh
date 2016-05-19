#!/bin/bash
cat << EOS
{
  "database-servers": {
    "hosts": [
      "10.0.0.4"
    ]
  },
  "application-servers": {
    "hosts": [
      "10.0.0.2",
      "10.0.0.3"
    ]
  },
  "web-servers": {
    "hosts": [
      "10.0.0.1"
    ]
  },
  "staging-database-servers": {
    "children": [
      "database-servers"
    ]
  },
  "staging-application-servers": {
    "children": [
      "application-servers"
    ]
  },
  "staging-web-servers": {
    "children": [
      "web-servers"
    ]
  },
  "staging": {
    "children": [
      "staging-web-servers",
      "staging-application-servers",
      "staging-database-servers"
    ]
  }
}
EOS
