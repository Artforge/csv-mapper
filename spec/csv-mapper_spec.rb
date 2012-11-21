require File.dirname(__FILE__) + '/spec_helper.rb'

describe CsvMapper do
  describe "included" do
    before(:each) do
      @mapped_klass = Class.new do
        include CsvMapper

        def upcase_name(row, index)
          row[index].upcase
        end
      end
      @mapped = @mapped_klass.new
    end

    it "should allow the creation of CSV mappings" do
      mapping = @mapped.map_csv do
        start_at_row 2
      end

      mapping.should be_instance_of(CsvMapper::RowMap)
      mapping.start_at_row.should == 2
    end

    it "should import a CSV IO" do
      io = 'foo,bar,00,01'
      results = @mapped.import(io, :type => :io) do
        first
        second
      end

      results.should be_kind_of(Enumerable)
      results.should have(1).things
      results[0].first.should == 'foo'
      results[0].second.should == 'bar'
    end

    it "should import a CSV File IO" do
      results = @mapped.import(File.dirname(__FILE__) + '/test.csv') do
        start_at_row 1
        [first_name, last_name, age]
      end

      results.size.should == 3
    end

    it "should stop importing at a specified row" do
      results = @mapped.import(File.dirname(__FILE__) + '/test.csv') do
        start_at_row 1
        stop_at_row 2
        [first_name, last_name, age]
      end

      results.size.should == 2
    end

    it "should be able to read attributes from a csv file" do
      results = @mapped.import(File.dirname(__FILE__) + '/test.csv') do
        # we'll alias age here just as an example
        read_attributes_from_file('Age' => 'number_of_years_old')
      end
      results[1].first_name.should == 'Jane'
      results[1].last_name.should == 'Doe'
      results[1].number_of_years_old.should == '26'
    end

    it "should import non-comma delimited files" do
      piped_io = 'foo|bar|00|01'

      results = @mapped.import(piped_io, :type => :io) do
        delimited_by '|'
        [first, second]
      end

      results.should have(1).things
      results[0].first.should == 'foo'
      results[0].second.should == 'bar'
    end

    it "should allow named tranformation mappings" do
      def upcase_name(row)
        row[0].upcase
      end

      results = @mapped.import(File.dirname(__FILE__) + '/test.csv') do
        start_at_row 1

        first_name.map :upcase_name
      end

      results[0].first_name.should == 'JOHN'
    end
  end

  describe "extended" do
    it "should allow the creation of CSV mappings" do
      mapping = CsvMapper.map_csv do
        start_at_row 2
      end

      mapping.should be_instance_of(CsvMapper::RowMap)
      mapping.start_at_row.should == 2
    end

    it "should import a CSV IO" do
      io = 'foo,bar,00,01'
      results = CsvMapper.import(io, :type => :io) do
        first
        second
      end

      results.should be_kind_of(Enumerable)
      results.should have(1).things
      results[0].first.should == 'foo'
      results[0].second.should == 'bar'
    end

    it "should import a CSV File IO" do
      results = CsvMapper.import(File.dirname(__FILE__) + '/test.csv') do
        start_at_row 1
        [first_name, last_name, age]
      end

      results.size.should == 3
    end

    it "should stop importing at a specified row" do
      results = CsvMapper.import(File.dirname(__FILE__) + '/test.csv') do
        start_at_row 1
        stop_at_row 2
        [first_name, last_name, age]
      end

      results.size.should == 2
    end

    it "should be able to read attributes from a csv file" do
      results = CsvMapper.import(File.dirname(__FILE__) + '/test.csv') do
        # we'll alias age here just as an example
        read_attributes_from_file('Age' => 'number_of_years_old')
      end
      results[1].first_name.should == 'Jane'
      results[1].last_name.should == 'Doe'
      results[1].number_of_years_old.should == '26'
    end

    describe "Adding only certain attributes by name or alias" do
      context "A file with headers and empty column names" do
        before :all do
          @results = CsvMapper.import(File.dirname(__FILE__) + '/test_with_empty_column_names.csv') do
            named_columns
            surname('Last Name')
            age.map { |row, index| row[index].to_i }
          end
        end

        it "should have Last name aliased as surname" do
          @results[1].surname.should == 'Doe'
        end

        it "should transform age to 26 (a Fixnum)" do
          @results[1].age.should == 26
        end

        it "should not have First Name at all" do
          lambda { @results[1].first_name }.should raise_error(NoMethodError)
        end

        it "should raise IndexError when adding non-existent fields" do
          lambda {
            @results = CsvMapper.import(File.dirname(__FILE__) + '/test_with_empty_column_names.csv') do
              add_attributes_by_name('doesnt_exist')
            end
          }.should raise_error(IndexError)
        end

        it "should raise IndexError when adding non-existent aliases" do
          lambda {
            @results = CsvMapper.import(File.dirname(__FILE__) + '/test_with_empty_column_names.csv') do
              my_new_field('doesnt_exist')
            end
          }.should raise_error(IndexError)
        end
      end

      context "A crazy not-really CSV file with some lines to ignore at the top" do
        before :all do
          @results = CsvMapper.import(File.dirname(__FILE__) + '/test_with_pushed_down_header.csv') do
            start_at_row 5
            named_columns
            surname('Last Name')
            age.map { |row, index| row[index].to_i }
          end
        end

        it "should transform age to 26" do
          @results[1].age.should == 26
        end

      end
    end

    it "should be able to assign default column names when column names are null" do
      results = CsvMapper.import(File.dirname(__FILE__) + '/test_with_empty_column_names.csv') do
        read_attributes_from_file
      end

      results[1]._field_1.should == 'unnamed_value'
    end

    it "should import non-comma delimited files" do
      piped_io = 'foo|bar|00|01'

      results = CsvMapper.import(piped_io, :type => :io) do
        delimited_by '|'
        [first, second]
      end

      results.should have(1).things
      results[0].first.should == 'foo'
      results[0].second.should == 'bar'
    end

    it "should not allow transformation mappings" do
      def upcase_name(row)
        row[0].upcase
      end

      (lambda do
        results = CsvMapper.import(File.dirname(__FILE__) + '/test.csv') do
          start_at_row 1

          first_name.map :upcase_name
        end
      end).should raise_error(Exception)
    end
  end
end
