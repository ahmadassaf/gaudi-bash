#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group

load ../../lib/helpers/generic

local_setup () {
  prepare
}

@test "bash-it helpers: generic: pathmunge: ensure function is defined" {

  run type -t pathmunge
  assert_line "function"
}

@test "bash-it helpers: generic: pathmunge: single path" {

  local new_paths="/tmp/fake-pathmunge-path"
  local old_path="${PATH}"

  pathmunge "${new_paths}"
  assert_equal "${new_paths}:${old_path}" "${PATH}"
}

@test "bash-it helpers: generic: pathmunge: single path, with space" {

  local new_paths="/tmp/fake pathmunge path"
  local old_path="${PATH}"

  pathmunge "${new_paths}"
  assert_equal "${new_paths}:${old_path}" "${PATH}"
}

@test "bash-it helpers: generic: pathmunge: multiple paths" {

  local new_paths="/tmp/fake-pathmunge-path1:/tmp/fake-pathmunge-path2"
  local old_path="${PATH}"

  pathmunge "${new_paths}"
  assert_equal "${new_paths}:${old_path}" "${PATH}"
}

@test "bash-it helpers: generic: pathmunge: multiple paths, with space" {

  local new_paths="/tmp/fake pathmunge path1:/tmp/fake pathmunge path2"
  local old_path="${PATH}"

  pathmunge "${new_paths}"
  assert_equal "${new_paths}:${old_path}" "${PATH}"
}

@test "bash-it helpers: generic: pathmunge: multiple paths, with duplicate" {

  local new_paths="/tmp/fake-pathmunge-path1:/tmp/fake pathmunge path2:/tmp/fake-pathmunge-path1:/tmp/fake-pathmunge-path3"
  local want_paths="/tmp/fake pathmunge path2:/tmp/fake-pathmunge-path1:/tmp/fake-pathmunge-path3"
  local old_path="${PATH}"

  pathmunge "${new_paths}"
  assert_equal "${want_paths}:${old_path}" "${PATH}"
}
