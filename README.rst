Robottelo Reporter:
===================
Minitest Plugin to generate xml report compatible with robottelo and betelgeuse output for polarion reporting.


Installation:
+++++++++++++


1- Add robottelo_reporter to your project gem file

.. code-block:: ruby

    gem 'robottelo_reporter'

2- install the dependencies

.. code-block:: bash

    $ bundler install


Usage:
++++++

The main goal of robottelo reporter is to bind test attributes to the xml report output.

Note: only tests with pid attribute set will be reported

1- extend your TestCase with Robottelo::Reporter::TestAttributes
2- before each test that we want to report call the function "test_attributes" with arg "pid"


.. code-block:: ruby

    require 'test_helper'
    require 'robottelo/reporter/attributes'

    class ExampleTesCase < Minitest::Test
      extend Robottelo::Reporter::TestAttributes

      test_attributes pid: '123456'
      def test_example_1
        assert true
      end

      test_attributes pid: '123457'
      def test_example_2
        assert true
      end
    end

3 - Update your Rakefile with minitest task


.. code-block:: ruby

    require 'robottelo/reporter/rake/minitest'

    task minitest: 'robottelo:setup:minitest'


4- Generate the reports


.. code-block:: bash

    $ bundle exec rake minitest test TESTOPTS=-v --trace


Console output:

.. code-block:: bash

    ** Invoke minitest (first_time)
    ** Invoke robottelo:setup:minitest (first_time)
    ** Execute robottelo:setup:minitest
    ** Execute minitest
    ** Invoke test (first_time)
    ** Execute test
    Robottelo Reporter initialization
    Run options: -v --robottelo-reporter --seed 211

    # Running:

    ExampleTesCase#test_example_1 = 0.00 s = .
    ExampleTesCase#test_example_2 = 0.00 s = .

    Finished in 0.001410s, 1418.0012 runs/s, 1418.0012 assertions/s.

    2 runs, 2 assertions, 0 failures, 0 errors, 0 skips

    Robottelo Reporter build finished: /home/user/projects/Project/test/reports/robottelo/robottelo-results.xml


This will generate one file at test/reports/robottelo/robottelo-results.xml with content

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <properties>
      </properties>
      <testsuite errors="0" failures="0" name="minitest" skips="0" tests="2" time="0.000012">
        <testcase classname="ExampleTesCase" name="test_example_1" time="0.000009">
          <properties>
            <property name="polarion-testcase-id" value="123456"/>
          </properties>
        </testcase>
        <testcase classname="ExampleTesCase" name="test_example_2" time="0.000003">
          <properties>
            <property name="polarion-testcase-id" value="123457"/>
          </properties>
        </testcase>
      </testsuite>
    </testsuites>


To generate a report with all Polarion properties fields, we have to export environment variables with the required properties

.. code-block:: bash

    $ export POLARION_PROPERTIES="response=name%3DProject 6&test-run-id=Project 6.3.1 centos7 Tier 1&project-id=PRJT6&user-id=prjt6_user&lookup-method=custom&variant=server&include-skipped=true&set-testrun-finished=true&dry-run=false"
    $ export POLARION_CUSTOM_PROPERTIES="isautomated=true&arch=x8664&variant=server&plannedin=Project_6_3_1_centos7"

Note: the properties are as url encoded variable, notice response=name%3DProject 6  that will be parsed as response="name=Project 6"

With this variables set The report will looks like

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <properties>
        <property name="polarion-test-run-id" value="Project 6.3.1 centos7 Tier 1"/>
        <property name="polarion-project-id" value="PRJT6"/>
        <property name="polarion-user-id" value="prjt6_user"/>
        <property name="polarion-lookup-method" value="custom"/>
        <property name="polarion-variant" value="server"/>
        <property name="polarion-include-skipped" value="true"/>
        <property name="polarion-set-testrun-finished" value="true"/>
        <property name="polarion-dry-run" value="false"/>
        <property name="polarion-response-name" value="Project 6"/>
        <property name="polarion-custom-isautomated" value="true"/>
        <property name="polarion-custom-arch" value="x8664"/>
        <property name="polarion-custom-variant" value="server"/>
        <property name="polarion-custom-plannedin" value="Project_6_3_1_centos7"/>
      </properties>
      <testsuite errors="0" failures="0" name="minitest" skips="0" tests="2" time="0.000008">
        <testcase classname="ExampleTesCase" name="test_example_1" time="0.000006">
          <properties>
            <property name="polarion-testcase-id" value="123456"/>
          </properties>
        </testcase>
        <testcase classname="ExampleTesCase" name="test_example_2" time="0.000002">
          <properties>
            <property name="polarion-testcase-id" value="123457"/>
          </properties>
        </testcase>
      </testsuite>
    </testsuites>


File Location:
++++++++++++++

By default the report is generated at location test/reports/robottelo/rebottelo-results.xml

In order to change the report name export variable "ROBOTTELO_REPORT_NAME"

.. code-block:: bash

   $ export ROBOTTELO_REPORT_NAME="other_report_name.xml"


If "CI_REPORTS" environment variable is set, the report location will be $CI_REPORTS/robottelo/report_name, where report name is the default or custom one.

To set an other location and file name set the report file path

.. code-block:: bash

   $ export ROBOTTELO_REPORT_PATH="custom_dir/other_dir/other_report_name.xml"

Note: The Directory will be created automatically if it does no exist


Generate report for one test file:

To generate the report for one test file use the ruby command by adding the --robottelo-reporter option

.. code-block:: bash

    $ bundle exec ruby -I"lib:test" test/example_test.rb -v --robottelo-reporter


command output:

.. code-block:: bash

    Robottelo Reporter initialization
    Run options: -v --robottelo-reporter --seed 39993

    # Running:

    ExampleTesCase#test_example_1 = 0.00 s = .
    ExampleTesCase#test_example_2 = 0.00 s = .

    Finished in 0.004316s, 463.3767 runs/s, 463.3767 assertions/s.

    2 runs, 2 assertions, 0 failures, 0 errors, 0 skips

    Robottelo Reporter build finished: project_dir/test/reports/robottelo/robottelo-results.xml


and of course the generated report content is the same as above.