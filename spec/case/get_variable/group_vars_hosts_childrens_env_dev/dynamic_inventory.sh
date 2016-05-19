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
  "develop-database-servers": {
    "children": [
      "database-servers"
    ]
  },
  "develop-application-servers": {
    "children": [
      "application-servers"
    ]
  },
  "develop-web-servers": {
    "children": [
      "web-servers"
    ]
  },
  "develop": {
    "children": [
      "develop-web-servers",
      "develop-application-servers",
      "develop-database-servers"
    ]
  }
}
EOS
