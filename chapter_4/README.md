# 第4章 "掛け算と割り算"

第3章では複数回の足し算と引き算を実装しました。第4章では掛け算と割り算を実装します。

chapter_4ディレクトリのなかの`sample.y`をコピーして`calc.y`を作りましょう。

```shell
$ cp sample.y calc.y
```

素直に`*`に関するルールを追加してみます。

```ruby
rule
  program: expr { p "program is #{val[0]}. result is #{result}." }
         ;

  expr: expr '+' term { result = val[0] + val[2]; p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | expr '-' term { result = val[0] - val[2]; p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
      | expr '*' term { result = val[0] * val[2]; p "#{val[0]} * #{val[2]} = #{val[0] * val[2]}" }
      | term { result = val[0]; p "term #{val[0]} is expr. result is #{result}." }
      ;

  term: NUMBER { result = val[0]; p "NUMBER is #{val[0]}. result is #{result}." }
      ;
end
```

うまくいきそうな感じがします。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
2 * 3
"NUMBER is 2. result is 2."
"term 2 is expr. result is 2."
"NUMBER is 3. result is 3."
"2 * 3 = 6"
"program is 6. result is 6."

Enter the formula:
2 * 3 * 4
"NUMBER is 2. result is 2."
"term 2 is expr. result is 2."
"NUMBER is 3. result is 3."
"2 * 3 = 6"
"NUMBER is 4. result is 4."
"6 * 4 = 24"
"program is 24. result is 24."

Enter the formula:
2 * 3 + 10
"NUMBER is 2. result is 2."
"term 2 is expr. result is 2."
"NUMBER is 3. result is 3."
"2 * 3 = 6"
"NUMBER is 10. result is 10."
"6 + 10 = 16"
"program is 16. result is 16."
```

一回目でうまくいくような作りにはなっていないのです...

```shell
$ ruby calc.rb
Enter the formula:
2 + 3 * 10
"NUMBER is 2. result is 2."
"term 2 is expr. result is 2."
"NUMBER is 3. result is 3."
"2 + 3 = 5"
"NUMBER is 10. result is 10."
"5 * 10 = 50"
"program is 50. result is 50."

Enter the formula:
q
Bye!
```

というわけで左から右へ出てきた順に計算をしていった結果、掛け算を先に計算してくれない電卓になっています。

解決するためには掛け算を`term`に割り当てて、数値を`primary`にします。

```ruby
rule
  program: expr { p "program is #{val[0]}. result is #{result}." }
         ;

  expr: expr '+' term { result = val[0] + val[2]; p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | expr '-' term { result = val[0] - val[2]; p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
      | term { result = val[0]; p "term #{val[0]} is expr. result is #{result}." }
      ;

  term: term '*' primary { result = val[0] * val[2]; p "#{val[0]} * #{val[2]} = #{val[0] * val[2]}" }
      | primary { result = val[0]; p "primary #{val[0]} is term. result is #{result}." }
      ;

  primary: NUMBER { result = val[0]; p "NUMBER is #{val[0]}. result is #{result}." }
         ;
end
```

すごく雑にいうと強くくっつくものほど下位のルールにするという感じです。

例えば足し算は`expr`になります。そして掛け算は`term`になります。`expr`(足し算)の要素に`term`(掛け算)を含めることができますが、一方で`term`(掛け算)の要素に`expr`(足し算)は含まれないという文法になっています。

```
2 + 3 * 10
    ^~~~~~ term
^~~~~~~~~~ expr '+' term => expr というルールがある

2 + 3 * 10
^~~~~ expr
^~~~~~~~~ expr '*' primary => term というルールはない
```

## 演習: 4-1 割り算を実装せよ

ヒント: `|` をつかって掛け算と同じところにルールを定義する。

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
         ;
end
```

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
10 / 2 + 3
"NUMBER is 10. result is 10."
"primary 10 is term. result is 10."
"NUMBER is 2. result is 2."
"10 / 2 = 5"
"term 5 is expr. result is 5."
"NUMBER is 3. result is 3."
"primary 3 is term. result is 3."
"5 + 3 = 8"
"program is 8. result is 8."

Enter the formula:
10 + 6 / 2
"NUMBER is 10. result is 10."
"primary 10 is term. result is 10."
"term 10 is expr. result is 10."
"NUMBER is 6. result is 6."
"primary 6 is term. result is 6."
"NUMBER is 2. result is 2."
"6 / 2 = 3"
"10 + 3 = 13"
"program is 13. result is 13."

Enter the formula:
10 * 2 / 4
"NUMBER is 10. result is 10."
"primary 10 is term. result is 10."
"NUMBER is 2. result is 2."
"10 * 2 = 20"
"NUMBER is 4. result is 4."
"20 / 4 = 5"
"term 5 is expr. result is 5."
"program is 5. result is 5."

Enter the formula:
q
Bye!
```
