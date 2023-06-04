# 第1章 "数字を受け取って数字を表示する"

さっそくはじめましょう。chapter_1ディレクトリのなかに`sample.y`というファイルがあります。パーサの定義はこの`.y`という拡張子のファイルにします [^1]。

まずは`sample.y`をコピーして`calc.y`を作りましょう。

```shell
$ cp sample.y calc.y
```

いきなりですが`calc.y`からパーサを作ってみましょう。Rake taskを用意してあるので`rake`を実行するだけでパーサが生成されます。

```shell
$ rake
Compiling parser ...
```

`calc.rb`というファイルができたので実行してみます。`Enter the formula:`と表示されるので、"1", "+"を試しに入力してみます。まだパーサを実装していないので`parse error on value`とエラーになってしまいます。`q`を入力して終了します。

```shell
$ ruby calc.rb
Enter the formula:
1

parse error on value 1 (error)

Enter the formula:
+

parse error on value "+" (error)

Enter the formula:
q
Bye!
```

第1章では数字を1つ読んで、その数字を表示するシンプルなパーサを作ります。`calc.y`を開いて`rule`の部分を見てみましょう。ここが文法のルールを定義している箇所です。

```ruby
rule
  program: /* none */ { result = 0 }
         ;

end
```

この部分を以下のように変更し、`rake`でパーサを再度生成して試してみます。

```ruby
rule
  program: NUMBER { p "Input is #{val[0]}" }
         ;

end
```

`1`や`123`を入力すると意図した通り`"Input is 1"`などのメッセージが表示されます。一方で`1 + 2`を入力するとエラーになります。足し算の実装は次の章で行うのでお楽しみに。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
1
"Input is 1"

Enter the formula:
123
"Input is 123"

Enter the formula:
1 + 2
"Input is 1"

parse error on value "+" (error)

Enter the formula:
q
Bye!
```

[^1]: Yaccの時代からの慣習に従いました。おそらく`.y`はYaccのYだと思います。
