# 第6章 "括弧の導入"

第5章までで電卓の実装は完了です。第6章では演算子優先順位(Operator Precedence)という機能をつかって少ないルールで同じ機能を実装します。

chapter_6ディレクトリのなかの`sample.y`をコピーして`calc.y`を作りましょう。

```shell
$ cp sample.y calc.y
```

これまでexpr, term, primaryを使い分けてきましたが、正直ちょっと面倒ですよね。本当はこんなふうにまとめて書きたいのではないかと思います。

```ruby
rule
  program: expr { p "program is #{val[0]}. result is #{result}." }
         ;

  expr: expr '+' expr { result = val[0] + val[2]; p "#{val[0]} + #{val[2]} = #{val[0] + val[2]}" }
      | expr '-' expr { result = val[0] - val[2]; p "#{val[0]} - #{val[2]} = #{val[0] - val[2]}" }
      | expr '*' expr { result = val[0] * val[2]; p "#{val[0]} * #{val[2]} = #{val[0] * val[2]}" }
      | expr '/' expr { result = val[0] / val[2]; p "#{val[0]} / #{val[2]} = #{val[0] / val[2]}" }
      | '(' expr ')'  { result = val[1]; p "( #{val[1]} ) is expr. result is #{result}." }
      | NUMBER        { result = val[0]; p "NUMBER #{val[0]} is expr. result is #{result}." }
      ;

end
```

ruleをこのように修正してrakeをしてみましょう。

```shell
$ rake
Compiling parser ...
16 shift/reduce conflicts
Turn on logging with "-v" and check ".output" file for details
```

"shift/reduce conflict"というものが出てしまいました。ざっくりいうと2通りの解釈が可能になってしまっているという状態です。

```
2 + 3 * 10
^~~~~ expr
^~~~~~~~~~~ expr '*' expr

2 + 3 * 10
    ^~~~~ expr
^~~~~~~~~~~ expr '+' expr
```

こういったときに演算子の優先順位を指定することがraccでは可能です。classとruleの間に4行追加します。preclow (Precedence low)、つまり上のものほど優先度が低く、下にいくほど高くなります。

```ruby
class Calc
  preclow
    left '+' '-'
    left '*' '/'
  prechigh

rule
...
```

今度はconflictが出ません。また期待通りに掛け算を優先しています。

```shell
$ rake
Compiling parser ...

$ ruby calc.rb
Enter the formula:
2 + 3 * 10
"NUMBER 2 is expr. result is 2."
"NUMBER 3 is expr. result is 3."
"NUMBER 10 is expr. result is 10."
"3 * 10 = 30"
"2 + 30 = 32"
"program is 32. result is 32."

Enter the formula:
q
Bye!
```

## 発展的な内容

### 優先度を逆にしてみる

`2 + 3 * 10 => 50`、`10 * 3 + 2 => 50`というように足し算が優先される電卓をつくってみます。

```shell
$ ruby calc.rb
Enter the formula:
2 + 3 * 10
"NUMBER 2 is expr. result is 2."
"NUMBER 3 is expr. result is 3."
"2 + 3 = 5"
"NUMBER 10 is expr. result is 10."
"5 * 10 = 50"
"program is 50. result is 50."

Enter the formula:
10 * 3 + 2
"NUMBER 10 is expr. result is 10."
"NUMBER 3 is expr. result is 3."
"NUMBER 2 is expr. result is 2."
"3 + 2 = 5"
"10 * 5 = 50"
"program is 50. result is 50."
```

### 足し算と引き算の間に優先度をつける

足し算よりも引き算が優先される電卓をつくってみます。計算結果は足し算と引き算の優先度が同じときと変わらないので、計算の途中結果を確認します。

```shell
$ ruby calc.rb
Enter the formula:
1 + 2 - 3
"NUMBER 1 is expr. result is 1."
"NUMBER 2 is expr. result is 2."
"NUMBER 3 is expr. result is 3."
"2 - 3 = -1"                      <-- 引き算が先に行われている
"1 + -1 = 0"
"program is 0. result is 0."

Enter the formula:
2 - 3 + 1
"NUMBER 2 is expr. result is 2."
"NUMBER 3 is expr. result is 3."
"2 - 3 = -1"
"NUMBER 1 is expr. result is 1."
"-1 + 1 = 0"
"program is 0. result is 0."
```

### 足し算と引き算の結合を右結合にする

`left '+' '-'`のleftとは左結合するという意味です。これをrightに変えて右結合になる様子を観察します。

```
1 + 2 + 3

((1 + 2) + 3)  <-- 左結合
(1 + (2 + 3))  <-- 右結合
```

```shell
$ ruby calc.rb
Enter the formula:
1 + 2 + 3
"NUMBER 1 is expr. result is 1."
"NUMBER 2 is expr. result is 2."
"NUMBER 3 is expr. result is 3."
"2 + 3 = 5"                        <-- 2 + 3を先に計算している
"1 + 5 = 6"
"program is 6. result is 6."
```
