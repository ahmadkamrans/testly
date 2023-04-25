#!/bin/sh

release_ctl eval --mfa "Testly.ReleaseTasks.migrate/1" --argv -- "$@"
