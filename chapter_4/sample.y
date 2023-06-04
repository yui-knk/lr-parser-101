class Calc

rule
  program: expr { p "program is #{val[0]}. result is #{result}." }
         ;

  expr: expr '+' term { result = val[0] + val[2]; p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | expr '-' term { result = val[0] - val[2]; p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
      | term { result = val[0]; p "term #{val[0]} is expr. result is #{result}." }
      ;

  term: NUMBER { result = val[0]; p "NUMBER is #{val[0]}. result is #{result}." }
      ;
end

---- header
# header

require 'strscan'

---- inner
# inner

  def parse(str)
    @q = []
    ss = StringScanner.new(str)

    while !ss.eos? do
      case
      when ss.scan(/\s+/)
        # skip spaces
      when ss.scan(/(\d+)/)
        @q << [:NUMBER, ss[0].to_i]
      when ss.scan(/\+/)
        @q << ['+', '+']
      when ss.scan(/\-/)
        @q << ['-', '-']
      when ss.scan(/\*/)
        @q << ['*', '*']
      when ss.scan(/\//)
        @q << ['/', '/']
      when ss.scan(/\(/)
        @q << ['(', '(']
      when ss.scan(/\)/)
        @q << [')', ')']
      else
        raise "Parse error (unknown token): #{ss.string[ss.pos]} (#{ss.string}, #{ss.pos})"
      end
    end

    @q << [false, '$end']

    do_parse
  end

  def next_token
    @q.shift
  end

---- footer
# footer

parser = Calc.new

while true do
  puts "Enter the formula:\n"
  str = gets.chomp

  if /\Aq/i =~ str
    puts "Bye!\n"
    exit
  end

  begin
    parser.parse(str)
  rescue => e
    puts e
  end

  puts "\n"
end
