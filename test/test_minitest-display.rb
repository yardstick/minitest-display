require 'helper'
require 'minitest/spec'

class TestMinitestDisplay < Minitest::Test

  def test_runs_basic_test_with_default_settings
    capture_test_output <<-TESTCASE
      describe "BasicTest" do

        it "asserts truth" do
          assert true
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end
    TESTCASE

    assert_output(/\.\./)
  end

  def test_runs_basic_test_with_failures
    capture_test_output <<-TESTCASE
      describe "BasicTest" do

        it "fails when asserting false" do
          assert false
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end
    TESTCASE

    assert_output(/BasicTest/)
    assert_output(/F/)
    assert_output(/\./)
  end

  def test_runs_basic_test_with_multiple_suites
    capture_test_output <<-TESTCASE

      describe "BasicTest" do

        it "fails when asserting false" do
          assert false
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end

      describe "AnotherBasicTest" do

        it "fails when asserting false" do
          assert false
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end
    TESTCASE

    assert_output(/^BasicTest |/)
    assert_output(/AnotherBasicTest |/)
    assert_output(/F/)
    assert_output(/\./)
  end

  def test_runs_basic_test_suite_with_different_printing
    capture_test_output <<-TESTCASE
      Minitest::Display.options = {
        :suite_divider => ' // ',
        :print => {
          :success => 'PASS'
        }
      }

      describe "PrintTest" do

        it "fails when asserting false" do
          assert false
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end
    TESTCASE

    assert_output(/PrintTest/)
    assert_output(/\/\//)
    assert_output(/F/)
    assert_output(/PASS/)
  end

  def test_runs_basic_test_with_slow_output
    capture_test_output <<-TESTCASE
      Minitest::Display.options = {
        :suite_divider => ' // ',
        :print => {
          :success => 'PASS'
        },
        :output_slow => true
      }

      describe "PrintTest" do

        it "fails when asserting false" do
          assert false
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end
    TESTCASE
    # assert_output(/PrintTest/)
    assert_output(/\/\//)
    assert_output(/F/)
    assert_output(/PASS/)
    assert_output(/Slowest tests:/)
  end

  def test_runs_basic_test_suite_with_slow_output_and_percent_sign
    capture_test_output <<-TESTCASE
      Minitest::Display.options = {
        :suite_divider => ' // ',
        :print => {
          :success => 'PASS'
        }
      }
      describe "Print%Test" do

        it "fails when asserting false" do
          assert false
        end

        it "accepts tests with a % sign in the name" do
          assert_equal "0%", "0%"
        end
      end
    TESTCASE

    assert_output(/Print%Test/)
    assert_output(/\/\//)
    assert_output(/F/)
    assert_output(/PASS/)
    assert_output(/Slowest tests:/)
  end

  def test_adding_a_recorder
    capture_test_output <<-TESTCASE
      Minitest::Display.options = {
        :suite_divider => ' // ',
        :print => {
          :success => 'PASS'
        }
      }
      class TestRecorder
        def initialize(runner)
          @runner = runner
        end

        def record(suite, method, assertions, time, error)
          puts "I just recorded \#{method}"
        end
      end

      Minitest::Display.add_recorder TestRecorder

      describe "PrintTest" do

        it "fails when asserting false" do
          assert false
        end

        it "asserts equality" do
          assert_equal 'test', 'test'
        end
      end
    TESTCASE

    assert_output(/PrintTest/)
    assert_output(/\/\//)
    assert_output(/F/)
    assert_output(/PASS/)
    assert_output(/I just recorded.*fails when asserting false/)
  end

  def test_fail_fast
    capture_test_output <<-TESTCASE
      Minitest::Display.options = {
        :fail_fast => true
      }

      describe "FailFastTest" do

        it "asserts truth" do
          assert true
        end

        it "fails when asserting false" do
          assert false
        end

        it "skips for fail_fast" do
          skip "This test should be skipped if fail_fast works"
        end
      end

      describe "PassTest" do
        it "asserts false" do
          assert false
        end
      end
    TESTCASE

    assert_output(/FailFastTest/)
    assert_output(/\./) # The first test should pass
    assert_output(/F/)  # The second test should fail
    assert_no_output(/This test should be skipped if fail_fast works/)
    assert_output(/PassTest/)
    assert_output(/F/)
  end
end
