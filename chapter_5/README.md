# 第5章 "括弧の導入"

第4章では掛け算と割り算を実装しました。第5章では括弧を実装します。

chapter_5ディレクトリのなかの`sample.y`をコピーして`calc.y`を作りましょう。

```shell
$ cp sample.y calc.y
```

`(2 + 3) * 10 => 50`を計算できるように括弧を実装します。

括弧の中にはなにが入るか考えてみましょう。`(NUMBER)`や`(primary)`だと嬉しさが少なそうです。`(term)`だと足し算や引き算が入れません。ということで`(expr)`と書けるようにするのがよさそうです。

では`(expr)`はexpr, term, primary, その他のどこに属するのでしょうか。強くくっつくものほど下位のルールなのでprimaryにしましょう。

```ruby
rule
  program: expr { p "program is #{val[0]}. result is #{result}." }
         ;

  expr: expr '+' term { result = val[0] + val[2]; p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | expr '-' term { result = val[0] - val[2]; p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
      | term { result = val[0]; p "term #{val[0]} is expr. result is #{result}." }
      ;

  term: term '*' primary { result = val[0] * val[2]; p "#{val[0]} * #{val[2]} = #{val[0] * val[2]}" }
      | term '/' primary { result = val[0] / val[2]; p "#{val[0]} / #{val[2]} = #{val[0] / val[2]}" }
      | primary { result = val[0]; p "primary #{val[0]} is term. result is #{result}." }
      ;

  primary: NUMBER { result = val[0]; p "NUMBER is #{val[0]}. result is #{result}." }
         | '(' expr ')' { result = val[1]; p "( #{val[1]} ) is primary. result is #{result}." }
         ;
end
```

これでよさそうです。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
(2 + 3) * 10
"NUMBER is 2. result is 2."
"primary 2 is term. result is 2."
"term 2 is expr. result is 2."
"NUMBER is 3. result is 3."
"primary 3 is term. result is 3."
"2 + 3 = 5"
"( 5 ) is primary. result is 5."
"primary 5 is term. result is 5."
"NUMBER is 10. result is 10."
"5 * 10 = 50"
"term 50 is expr. result is 50."
"program is 50. result is 50."

Enter the formula:
2 + 3 * 10
"NUMBER is 2. result is 2."
"primary 2 is term. result is 2."
"term 2 is expr. result is 2."
"NUMBER is 3. result is 3."
"primary 3 is term. result is 3."
"NUMBER is 10. result is 10."
"3 * 10 = 30"
"2 + 30 = 32"
"program is 32. result is 32."

Enter the formula:
q
Bye!
```
