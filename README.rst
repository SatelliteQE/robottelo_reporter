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

    $ bundle exec rake minitest test


This will generate one file at test/reports/robottelo-results.xml with content

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <properties>
      </properties>
      <testsuite errors="0" failures="0" name="minitest" skips="0" tests="2" time="1.0e-05">
        <testcase classname="ExampleTesCase" name="test_example_1" time="1.0e-05">
          <properties>
            <property name="polarion-testcase-id" value="123456"/>
          </properties>
        </testcase>
        <testcase classname="ExampleTesCase" name="test_example_2" time="0.0">
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
      <testsuite errors="0" failures="0" name="minitest" skips="0" tests="2" time="2.0e-05">
        <testcase classname="ExampleTesCase" name="test_example_1" time="1.0e-05">
          <properties>
            <property name="polarion-testcase-id" value="123456"/>
          </properties>
        </testcase>
        <testcase classname="ExampleTesCase" name="test_example_2" time="0.0">
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


If "CI_REPORTS" environment variable is set the report location will be $CI_REPORTS/robottelo/report_name , where report is the default or custom one.

To set an other location and file name set the report file path

.. code-block:: bash

   $ export ROBOTTELO_REPORT_PATH="custom_dir/other_dir/other_report_name.xml"

Note: The Directory will be created automatically if it does no exist

