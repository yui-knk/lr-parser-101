# 第3章 "複数回の足し算と引き算"

第2章では3つのルールを実装しました。第3章では引き続き足し算と引き算についてみていきます。じつは第2章の足し算と引き算の実装は不完全なのです。

1. 足し算
2. 引き算
3. 数値が一つ

chapter_3ディレクトリのなかの`sample.y`をコピーして`calc.y`を作りましょう。

```shell
$ cp sample.y calc.y
```

`1 + 2 + 3`のように複数回の足し算や引き算だとエラーになってしまいます。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 2 + 3
"1 + 2 = 3"

parse error on value "+" ("+")

Enter the formula:
q
Bye!
```

ルールをじっくりみるとわかるのですが、いまのルールの定義は`NUMBER '+' NUMBER`を許可していますが、`NUMBER '+' NUMBER '+' NUMBER`を許可していません。素直に`program: NUMBER '+' NUMBER '+' NUMBER`を定義してみましょう。

```ruby
rule
  program: NUMBER '+' NUMBER { p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
         | NUMBER '+' NUMBER '+' NUMBER { p "#{val[0]} + #{val[2]} + #{val[4]} = #{val[0] + val[2] + val[4]}" }
         | NUMBER '-' NUMBER { p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
         | NUMBER { p "Input is #{val[0]}" }
         ;

end
```

`1 + 2 + 3`はokだけど、`1 + 2 + 3 + 4`は通りません。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 2 + 3
"1 + 2 + 3 = 6"

Enter the formula:
1 + 2 + 3 + 4
"1 + 2 + 3 = 6"

parse error on value "+" ("+")

Enter the formula:
q
Bye!
```

ではどうするか。再帰的な定義をすることでこの問題を解決します。説明を簡単にするために一度引き算の実装をやめています。

```ruby
rule
  program: expr { p "Result is #{val[0]}" }
         ;

  expr: expr '+' term { p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | term { p "term #{val[0]} is expr" }
      ;

  term: NUMBER { p "NUMBER is #{val[0]}" }
      ;
end
```

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1
"NUMBER is 1"
"term 1 is expr"
"Result is 1"

Enter the formula:
1 + 2
"NUMBER is 1"
"term 1 is expr"
"NUMBER is 2"
"1 + 2 = 3"
"Result is 1"

Enter the formula:
1 + 2 + 3
"NUMBER is 1"
"term 1 is expr"
"NUMBER is 2"
"1 + 2 = 3"
"NUMBER is 3"
"1 + 3 = 4"
"Result is 1"

Enter the formula:
q
Bye!
```

急に複雑になったのでゆっくりみていきましょう。

まずは`1 + 2`のケース。これは以下のように定義されてます。

```
program: expr
program: expr   '+' term
program: expr   '+' NUMBER
program: term   '+' NUMBER
program: NUMBER '+' NUMBER
```

つぎに`1 + 2 + 3`のケース。これは以下のように定義されてます。

```
program: expr
program: expr   '+' term
program: expr   '+' NUMBER
program: expr   '+' term   '+' NUMBER
program: expr   '+' NUMBER '+' NUMBER
program: term   '+' NUMBER '+' NUMBER
program: NUMBER '+' NUMBER '+' NUMBER
```

ポイントは`expr: expr '+' term`の部分で、このルールで無限の長さの足し算を定義しています。

```
expr: expr '+' term
      ^~~~ ここを expr '+' term に展開する
expr: expr '+' term '+' term
      ^~~~ ここを expr '+' term に展開する
expr: expr '+' term '+' term '+' term
...
```

というわけで再帰的な定義をすることで無限の長さの足し算を4つのルールで定義することができました。残った問題は計算の結果が上手く保存されていないことです。`1 + 2 + 3`をみるとよくわかるのですが途中から計算結果がおかしくなっています。

```
Enter the formula:
1 + 2 + 3
"NUMBER is 1"
"term 1 is expr"
"NUMBER is 2"
"1 + 2 = 3"
"NUMBER is 3"
"1 + 3 = 4"      <-- おかしい。3 + 3 = 6のはず
"Result is 1"    <-- おかしい。6のはず
```

途中の計算結果を保存する場所としてraccは`result`という変数を提供しているのでそれを使います。

```ruby
rule
  program: expr { p "program is #{val[0]}. result is #{result}." }
         ;

  expr: expr '+' term { result = val[0] + val[2]; p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | term { result = val[0]; p "term #{val[0]} is expr. result is #{result}." }
      ;

  term: NUMBER { result = val[0]; p "NUMBER is #{val[0]}. result is #{result}." }
      ;
end
```

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1
"NUMBER is 1. result is 1."
"term 1 is expr. result is 1."
"program is 1. result is 1."

Enter the formula:
1 + 2
"NUMBER is 1. result is 1."
"term 1 is expr. result is 1."
"NUMBER is 2. result is 2."
"1 + 2 = 3"
"program is 3. result is 3."

Enter the formula:
1 + 2 + 3
"NUMBER is 1. result is 1."
"term 1 is expr. result is 1."
"NUMBER is 2. result is 2."
"1 + 2 = 3"
"NUMBER is 3. result is 3."
"3 + 3 = 6"
"program is 6. result is 6."

Enter the formula:
q
Bye!
```

今度は正しく計算結果が受け渡されています。

```
Enter the formula:
1 + 2 + 3
"NUMBER is 1. result is 1."
"term 1 is expr. result is 1."
"NUMBER is 2. result is 2."
"1 + 2 = 3"
"NUMBER is 3. result is 3."
"3 + 3 = 6"                   <-- 正しい
"program is 6. result is 6."  <-- 正しい
```

アクションの計算結果を`result`にいれることで左辺の値を設定し、次のアクションで右辺の値として取り出しています。

```
expr: expr '+' term
 3     1    +   2

expr: expr '+' term
 6     3    +   3
      ^~~~ ひとつ前の左辺のexprの値
```

## 演習: 3-1 引き算を実装せよ

ヒント: `|` をつかって複数のルールを定義することができる。

```ruby
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
```

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1 + 4 + 10
"NUMBER is 1. result is 1."
"term 1 is expr. result is 1."
"NUMBER is 4. result is 4."
"1 + 4 = 5"
"NUMBER is 10. result is 10."
"5 + 10 = 15"
"program is 15. result is 15."

Enter the formula:
10 - 1 - 2
"NUMBER is 10. result is 10."
"term 10 is expr. result is 10."
"NUMBER is 1. result is 1."
"10 - 1 = 9"
"NUMBER is 2. result is 2."
"9 - 2 = 7"
"program is 7. result is 7."

Enter the formula:
10 + 20 - 3
"NUMBER is 10. result is 10."
"term 10 is expr. result is 10."
"NUMBER is 20. result is 20."
"10 + 20 = 30"
"NUMBER is 3. result is 3."
"30 - 3 = 27"
"program is 27. result is 27."

Enter the formula:
10 - 4 + 20
"NUMBER is 10. result is 10."
"term 10 is expr. result is 10."
"NUMBER is 4. result is 4."
"10 - 4 = 6"
"NUMBER is 20. result is 20."
"6 + 20 = 26"
"program is 26. result is 26."

Enter the formula:
q
Bye!
```

## 発展的な内容

### LRパーサのLとR

L: Left to right. つまり入力を左から右に読んでいく(かつ戻らない)
R: Rightmost derivation. つまり最も右の非終端記号を展開していったときと同じ展開形になる(最右導出)

Rのほうについて説明しておくと `1 + 2 + 3` をパースしたときの順番が最も右の非終端記号を展開していったときと同じ形になっています。正確には下から上にしたものと一致しています。

```
Enter the formula:
1 + 2 + 3

7) "NUMBER is 1. result is 1."
6) "term 1 is expr. result is 1."
5) "NUMBER is 2. result is 2."
4) "1 + 2 = 3"
3) "NUMBER is 3. result is 3."
2) "3 + 3 = 6"
1) "program is 6. result is 6."
```

```
1) program: expr
2) program: expr   '+' term
3) program: expr   '+' NUMBER
4) program: expr   '+' term   '+' NUMBER
5) program: expr   '+' NUMBER '+' NUMBER
6) program: term   '+' NUMBER '+' NUMBER
7) program: NUMBER '+' NUMBER '+' NUMBER
              1    '+'  2     '+' 3
```
