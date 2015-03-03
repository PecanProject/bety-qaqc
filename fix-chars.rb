# -*- coding: utf-8 -*-

InfoText = <<INFO

This script may be used to help correct mis-encoded characters in a
Rails database.  It is primarily useful for legacy databases in which
characters were originally encoded as UTF-8 multi-byte sequences in
tables or columns labelled as windows-1252 (latin1 in MySQL) and then
the constituent characters were themselves re-encoded as UTF-8
multi-byte sequences and inserted into a table or column labelled as
UTF-8.

The script is meant to be used in conjunction with a Rails
application.  Command line options allow choosing the Rails
application to use and the Rails environment to run in.

The script currently must be run interactively.

The first significant user choice is whether to run in search or fix
mode.  Search mode is meant to be used primarily for finding encoding
problems and proposing corrections.  Fix mode is a more controlled
mode in that it uses a well-defined list of substitutions.  Either
mode, however, may be used to view possibly corrections and either
update the database by accepting the proposed correction or not.

Once a mode has been chosen, the user is presented with a possible
mis-encoding and proposed correction.  At this point the user is given
the option to (i) accept the correction and go on to the next; (ii)
accept the correction and all subsequent ones without being asked;
(iii) turn down the correction and go on to the next; (iv) turn down
the correction and all subsequent ones (in this case, all the proposed
corrections are sent to standard output, but the user won't have the
opportunity to accept any of them without re-running the program); (v)
abort the program.

Recommended use scenario:

1. Run the program in fix mode and accept all the recommended changes.
(This is relatively safe since the substitution list comprises a set
of sensible substitutions.)

2. Re-run the program in search mode to find problems that were not
addressed by the substitutions contained in the substitution list.

3. If there are only a few such cases, they may be accepted or denied
interactively.  But if there are repeated cases involving the same
character sequence, abort the script, add these cases to the
substitution list, and re-run the program in fix mode to correct all
of these previously-uncaught cases.

4. Repeat these steps as necessary.


Format of the substitution list:

The $Substitutions variable is an Array of Hashes.  Each Hash contains
two required keys and possibly two optional ones.  All values are
UTF8-encoded strings.

The required keys are :old and :new.

:old is a string of characters that are contained in the windows-1252
character set (although in this case they are encoded as UTF8).  The
string is such that if encoded in the windows-1252 encoding, the
resulting byte sequence will correspond to the UTF-8 encoding of one
or more characters.

:new is either this corresponding UTF-8 character (or string of
characters), or is the result of multiple iterations of this
transformation.  It will be used as the replacement for :old unless
the :use key is given.

:use is the replacement string to use for the substitution.  If not
given, :new is used.  An example where this key might be used is for
eliminating mis-encodings of the unicode 'zero-width space' character
entirely instead of simply substituting the correct encoding.

:context is a format string and is used to limit the substitution to
certain contexts.  It should contain one '%s' place holder to mark the
position of the :old character sequence and should generally (once the
'%s' is replaced with the :old string) take the form of a regular
expression.  For example '%s$' could be used to limit substitution for
a character sequence to cases where it occurs at the end of the column
value.

Interacting with a remote database:

Usually the databases configured for use with a Rails application are
local ones.  To use this script to update a remote database, there are
two options:

1. Upload the script to a server containing a copy of the Rails
application that uses that remote database.

2. Choose a local copy of the Rails application and add a new Rails
environment to database.yml that points to the remote database.  This
can be done in one of two ways:

a. If the remote database allows it, set the host to the remote server
and the login credentials to some user that has remote access
privileges from your IP address.

b. Set up a tunnel to the remote database before running the script
and set the port in the database configuration to the local port that
the tunnel uses.

Once the new Rails environment has been set up, pass it to the script
using the -e option.

INFO

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = <<BANNER
____________
fix-chars.rb
____________

Usage:

  fix-chars.rb [(-r|--app) <path>] [(-e|--environment) <rails environment>]
  fix-chars.rb (-?|-h|--help) | (--info|--man)

BANNER

  opts.on("-r <path>", '--app <path>', 'Path to Rails root', '  (default "..")') do |p|
    options[:path] = p
  end
  options[:path] ||= ".."

  opts.separator ""

  opts.on("-e <rails environment>", "--environment <rails environment>", "Set the Rails environment", "  (default is the value of shell variable RAILS_ENV)") do |e|
    ENV['RAILS_ENV'] = e
  end

  opts.separator ""
  opts.separator "Help Options"
  opts.separator ""

  # HELP OPTIONS

  opts.on_tail("--usage", "Show command-line syntax\n\n") do
    puts opts.banner
    exit
  end

  opts.on_tail("-?", "-h", "--help", "Show and explain all command-line options\n\n") do
    puts opts
    exit
  end

  opts.on_tail("--info", "--man", "Display comprehensive help on how to use this script\n\n") do
  # use system call to page the info text
    exec "echo \"#{opts}\n#{InfoText}\" | less"
  end

end.parse!


require File.join(options[:path], 'config', 'environment.rb')

$global_count = 0

def prompt(prompt_string = "?", default = "")
  print "#{prompt_string}"
  response = gets
  response.chomp!
  return response == "" ? default : response
end


# str is assumed to be a valid utf8-encoded string
#
# decode tests for the case where the individual bytes of a utf8
# multibyte-sequence for a non-ascii character have themselves been
# interpreted as windows-1252 characters and then replaced by the utf8
# multibyte sequence for the corresponding unicode codepoint.  It
# tries to undo these "over-encodings" and return the presumed
# original utf8 string.
#
# During the decoding process, several cases may occur:
#
# 1. str contains unicode characters that can't be represented in the
# windows-1252 encoding.  In this case, str is assumed not to be
# re-encoded and the method has no work to do. [either return str or
# raise a NothingToDo Exception]
#
# 2. str can be encoded in in windows-1252 but the byte sequence in
# the resulting string can't be interpreted as a valid utf8 encoding.
# This may happen, for example, if str contains single
# windows1252-encodable characters.  Again, in this case, str is
# assumed not to be re-encoded and the method has no work to do.
#
# 3. str can be encoded as a windows-1252 string, and the
# byte-sequence in this windows-1252-encoded string is a valid utf-8
# encoding of some string.  In this case, decode actually does some
# decoding work.  But before it returns a result, the decoding process
# is attempted again.  This will continue until either:
#
# a. The IterationLimit is reached.  In this case the result of the
# last decoding step is returned.
#
# b. The force_encoding step fails.  In this case, the last valid
# utf8-encoded version of the string is returned.
#
# c. The windows-1252 encoding step fails.  In this case, the string
# that could not be encoded into windows-1252 is returned (which is
# also the last valid utf8-encoded version of the string).
#
# If str is either not utf8-encoded or is not a valid utf8 string, and
# ArgumentError is raised.
class NothingToDoException < RuntimeError
end
IterationLimit = 10
def decode(str)

  if str.encoding != Encoding::UTF_8
    raise ArgumentError, "decode only takes utf8-encoded strings but #{str} has encoding #{str.encoding}"
  end
  if str.valid_encoding? == false
    raise ArgumentError, "argument str (#{str}) isn't a valid utf-8 string"
  end

  # check if str is ascii; if so, there's nothing to do!
  if str.ascii_only?
    raise NothingToDoException
  end

  decoded_str = str

  first_time = true
  1.upto(IterationLimit) do |i|
    if i > 1
      first_time = false
    end
    # make a windows-1252 string 'decoded-string' from the utf-8 string str having the same character sequence
    decoded_str = str.encode('windows-1252')

    # change decoded_str from a windows-1252 string to a utf-8 string having the same byte sequence
    decoded_str.force_encoding('utf-8')

    if decoded_str.valid_encoding? == false
      raise Encoding::InvalidByteSequenceError
    end

    if decoded_str == str
      raise "We shouldn't get here!"
    end

    str = decoded_str
  end

rescue Encoding::UndefinedConversionError => e

  # At this point, str contains unicode characters not encodable as windows-1252.  Return the current version of str.
  if first_time
    raise NothingToDoException
  end
  return str

rescue Encoding::InvalidByteSequenceError => e

  # At this point, str is encodable as windows-1252, but the resulting byte sequence can't be interpreted as a valid utf8-encoding of a string.  Return the current version of str.
  if first_time
    raise NothingToDoException, "Nothing to do!!!"
  end
  return str

else # we did IterationLimit iterations without error

  raise "I wouldn't expect to ever get here!!! #{IterationLimit} iterations should be plenty!!!"

  return decoded_str
end

$Substitutions = [
                  { old: 'Âµ', new: 'µ' },
                  { old: 'â€“', new: '–' }, # ndash
                  { old: 'â€”', new: '—' }, # mdash
                  { old: 'Î´', new: 'δ' },
                  { old: 'â€‹', new: '​', use: '' }, # this is U+200B "zero-width space" and can be safely eliminated
                  { old: 'Â ', context: '%s$', new: ' ', use: '' }, # this is U+00A0 "no-break space" and can be eliminated at the end of a string
                  { old: 'Ãƒâ€”', new: '×' },
                  { old: 'Ã—', new: '×' },
                  { old: 'Â°', new: '°' },
                  { old: 'Â·', new: '·' },
                  { old: 'Â±', new: '±' },
                  { old: 'Â®', new: '®' },
                  { old: 'â€™', new: '’' },
                  { old: 'Ã¡', new: 'á' },
                  { old: 'Ã§', new: 'ç' },
                  { old: 'Ã£', new: 'ã' },
                  { old: 'âˆ’', new: '−' }, # minus sign
                  { old: 'Ã©', new: 'é' },
                  { old: 'Ã¼', new: 'ü' },
                  { old: 'Ã±', new: 'ñ' },
                  { old: 'Ã‰', new: 'É' },
                  { old: 'Ã¢', new: 'â' },
                  { old: 'Ã³', new: 'ó' },
                  { old: 'Ã­', new: 'í' },
                  { old: 'Ã½', new: 'ý' },
                  { old: 'Å™', new: 'ř' },
                  { old: 'Å¾', new: 'ž' }#,
                  #{ old: '', new: '' },
                 ]

def check_substitution_table
  errors = false
  $Substitutions.each do |sub|
    begin
      if sub[:new] != decode(sub[:old])
        puts "Something's wrong with the substitution |#{sub[:old]}| -> |#{sub[:new]}|"
        errors = true
      else
        puts "|#{sub[:old]}| -> |#{sub[:new]}| is OK!"
      end
    rescue NothingToDoException => e
      puts "|#{sub[:old]}| doesn't seem to contain anything worthy of substitution.  This is probably an error."
      errors = true
    end
  end
  if errors
    exit!
  end
end

def do_substitutions(str)

  clarified_str = str

  $Substitutions.each do |substitution|
    #puts "Before substitution, str = #{str}"
    substituend = sprintf((substitution[:context] || "%s"), substitution[:old])
    replacement = substitution[:use] || substitution[:new]
    clarified_str = clarified_str.gsub(Regexp.new(substituend), replacement)
    #puts "After substitution, clarified_str = #{clarified_str}"
  end

  if clarified_str == str
    #puts str
    #puts clarified_str
    #puts
    raise NothingToDoException
  end
  clarified_str
end

  

def search_for_bad_chars(hash)

  table = hash['table_name']
  column = hash['column_name']

  sql = "SELECT id, \"#{column}\" FROM \"#{table}\" WHERE \"#{column}\" " ' ~ \'[\200-\377]\''


  records_array = ActiveRecord::Base.connection.execute(sql)

  if records_array.count == 0
    return
  end

  puts "#{table}.#{column}"

  records_array.each do |row|

    str = row["#{column}"]

    $global_count += 1

    
    begin
      decoded_str = unscramble(str)
    rescue NothingToDoException
      next
    end
    
    puts "column \"#{column}\" of row #{row['id']} of \"#{table}\"" 
    puts "original: #{str}"
    puts "proposed: #{decoded_str}"

    if !$update.nil?
      update = $update
    else
      update = prompt("Do you want to use the updated string?\ny = yes | n = no | a = yes to all | x = no to all | q = quit (default: no)", "n")
    end

    if update == 'a'
      update = $update = 'y'
    elsif update == 'x'
      update = $update = 'n'
    end

    if update == 'q'
      exit!
    elsif update == 'y'
      eval(table.sub('species', 'specie').classify.sub('Method', 'Methods').sub('Dbfile', 'DBFile')).update(row['id'], column.to_sym => decoded_str)
    # else
      # user answer 'n' or something not in the list (which will count as no)
    end
    
    puts "\n\n\n\n\n"

  end

end

# main

db_config = Rails.configuration.database_configuration[Rails.env] 
host = db_config['host'] || 'localhost'
database = db_config['database']

puts "This is your database configuration:"
puts db_config.to_yaml
puts  "\nEnter q to quit, any other key to continue)"
if (gets =~ /^ *q/)
  exit
end

puts "Working with database #{database} on host #{host}"

sql = <<QUERY
SELECT table_name, column_name 
  FROM information_schema.columns 
  WHERE table_catalog = '#{database}' 
    AND table_schema = 'public' 
    AND is_updatable = 'YES' 
    AND data_type IN ('character', 'character varying', 'text')
QUERY

records_array = ActiveRecord::Base.connection.execute(sql)

puts "We will examine #{records_array.count} textual columns in the database."

mode = prompt "Do you want to run in search mode (s) or fix mode (f)? (default: s) ", "s"

if mode == 's'
  alias unscramble decode
else
  check_substitution_table
  alias unscramble do_substitutions
end

records_array.each do |row|
  if row["table_name"] != "schema_migrations"
    search_for_bad_chars(row)
  end
end

puts "#{$global_count} column values were examined"
