#!/usr/bin/env bats

load ../helper
load ../../lib/composure

# Determine which config file to use based on OS.
case $OSTYPE in
  darwin*)
    export BASH_IT_CONFIG_FILE=.bash_profile
    ;;
  *)
    export BASH_IT_CONFIG_FILE=.bashrc
    ;;
esac

local_setup () {
  setup_test_fixture
}

@test "install: verify that the install script exists" {
  assert_file_exist "$BASH_IT/setup.sh"
}

@test "install: run the install script silently" {
  cd "$BASH_IT"

  ./setup.sh --silent

  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/plugins/enabled/todo.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/todo.plugin.bash"
  # assert_link_exist "$BASH_IT/enabled/350---todo.plugin.bash"
  # assert_link_exist "$BASH_IT/enabled/150---general.aliases.bash"
  # assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"
  # assert_link_exist "$BASH_IT/enabled/365---alias-completion.plugin.bash"
  # assert_link_exist "$BASH_IT/enabled/350---bash-it.completion.bash"
  # assert_link_exist "$BASH_IT/enabled/350---system.completion.bash"
}

@test "install: verify that a backup file is created" {
  cd "$BASH_IT"

  touch "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  echo "test file content" > "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  local md5_orig=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

  ./setup.sh --silent

  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak"

  local md5_bak=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

  assert_equal "$md5_orig" "$md5_bak"
}

@test "install: verify that silent and interactive can not be used at the same time" {
  cd "$BASH_IT"

  run ./setup.sh --silent --interactive

  assert_failure
}
