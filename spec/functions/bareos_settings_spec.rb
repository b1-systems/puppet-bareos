require 'spec_helper'
indent_default = '  '

describe 'bareos_settings' do
  context 'type is an integer' do
    %w[int32 pint16 pint32 port max_blocksize].each do |type|
      it 'runs with compatible values' do
        [0, 1, 3849, 222, '2'].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        ['string', { 'hash' => 'val' }].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is an resource name' do
    %w[name res resource].each do |type|
      it 'runs with compatible values and is quoted' do
        ['This is an string', 'combatible Res_Name-7.9', 'a' * 127].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = \"#{val}\"")
        end
      end
      it 'not runs with incompatible values' do
        ['0 number start', ' space', '.point', 'a' * 128].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is an string' do
    %w[acl messages type string_noquote schedule_run_command].each do |type|
      it 'runs with compatible values' do
        ['Not a number', 'MyString', '23 free usage of Text.!', 'Special ".-,= Chars'].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        [0, -1, 2, { 'hash' => 'val' }].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is an string with quotes' do
    %w[audit-command runscript_short autopassword md5password directory string strname address device plugin_names].each do |type|
      it 'runs with compatible values' do
        ['Not a number', 'MyString', '23 free usage of Text.!', 'Special ".-,= Chars'].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = \"#{val}\"")
        end
      end
      it 'not runs with incompatible values' do
        [0, -1, 2, { 'hash' => 'val' }, %w[array of string]].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is speed' do
    %w[speed].each do |type|
      it 'runs with compatible values' do
        ['0 k/s', '49Kb/s', '1 m/s', '200MB/s'].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        ['M', 50, 'k/s', '', ' '].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is size' do
    %w[size64].each do |type|
      it 'runs with compatible values' do
        ['6k', '400 KB', '5083 m', '100g', '10 GB'].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        ['M', 50, 'GB', '', ' '].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  # add time

  context 'type is boolean' do
    %w[boolean bit].each do |type|
      it 'runs with compatible values' do
        ['yes', 'NO', 'on', 'OFF', 'TRUE', 'false', true, false].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        [0, 1, 'true s', 'false s'].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  # add addresss
  context 'type is an hashed addresses value' do
    %w[addresses].each do |type|
      it 'runs with compatible values' do
        val = {
          'ip' => {
            'addr' => '1.2.3.4',
            'port' => '1205'
          }
        }
        result = "#{indent_default}Test = {
#{indent_default}#{indent_default}ip = {
#{indent_default}#{indent_default}#{indent_default}addr = 1.2.3.4
#{indent_default}#{indent_default}#{indent_default}port = 1205
#{indent_default}#{indent_default}}
#{indent_default}}"
        is_expected.to run.with_params([val, 'Test', type, true]).and_return(result)
      end
      it 'not runs with incompatible values' do
        ['wrong', 222, ['array'], false, true].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end
  # add include_exclude_time / hash
  context 'type is an hashed value' do
    %w[include_exclude_item runscript hash].each do |type|
      it 'runs with compatible values' do
        val = {
          'My Directive' => 'content',
          'Array'        => %w[a1 b2],
          'Second Hash'  => {
            'Res'        => 'Val'
          }
        }
        result = "#{indent_default}Test {
#{indent_default}#{indent_default}My Directive = content
#{indent_default}#{indent_default}Array = a1
#{indent_default}#{indent_default}Array = b2
#{indent_default}#{indent_default}Second Hash {
#{indent_default}#{indent_default}#{indent_default}Res = Val
#{indent_default}#{indent_default}}
#{indent_default}}"
        is_expected.to run.with_params([val, 'Test', type, true]).and_return(result)
      end
      it 'not runs with incompatible values' do
        ['wrong', 222, ['array'], false, true].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is backup_level' do
    %w[backup_level].each do |type|
      it 'runs with compatible values' do
        %w[Full incremental differential VirtualFull].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        ['wrong', 'fully', ' Full'].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is io_direction' do
    %w[io_direction].each do |type|
      it 'runs with compatible values' do
        %w[in out BOTH].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        ['wrong', ' in'].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is action_on_purge' do
    %w[action_on_purge].each do |type|
      it 'runs with compatible values' do
        %w[truncate Truncate].each do |val|
          is_expected.to run.with_params([val, 'Test', type, true]).and_return("#{indent_default}Test = #{val}")
        end
      end
      it 'not runs with incompatible values' do
        ['wrong', ' truncate'].each do |val|
          is_expected.not_to run.with_params([val, 'Test', type, true])
        end
      end
    end
  end

  context 'type is not compatible' do
    %w[invalid doesNotExist really_not_exists].each do |type|
      it 'raise error' do
        is_expected.to run.with_params([1, 'Test', type, true]).and_raise_error(Puppet::ParseError, %r{Invalid setting type})
      end
    end
  end
end