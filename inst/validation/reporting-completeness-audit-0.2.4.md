# mfrmr 0.2.4 開発版：論文報告の点検記録

点検日：2026-09-13。対象：`development` の 0.2.4.9000。

## 結論と対象範囲

既存の報告関数には、推定結果、精度、適合、カテゴリー、報告上の留保を
まとめる機能がある。一方、従来の例では、数値表を表示せずオブジェクト名や
表題の確認で終わる部分があり、研究の問いから結果の解釈までを追いにくかった。
研究レベルで必要な情報も、自動出力の外で何を補うかが十分に具体化されていなかった。

今回は、ワークフロー後半と reporting/APA vignette を点検・改訂し、既存の
関数を使って「問い → 分析とその理由 → 数値 → 答え」を示した。
報告ガイドの15項目の対応表は、各項目の出力元と著者が補う情報を区別する。
これによって論文全体の完成や特定誌の受理可能性を保証するものではない。

- [報告ガイド](../../vignettes/mfrmr-reporting-and-apa.Rmd)
- [ワークフロー](../../vignettes/mfrmr-workflow.Rmd)
- [報告ヘルプの原稿](../../R/help_reporting_and_apa.R)
- [チェックリストの原稿](../../R/api-reporting-checklist.R)

## 確認した問題と修正

| 確認事項 | 修正・明確化 |
| --- | --- |
| 合成データの rubric が「0–4」と記載されていた | 実際の1–4へ修正し、実研究と誤認しない context を指定した。 |
| 短時間用の積分設定や再推定が基本の報告例に混在 | 既定の31点MML/RSMを使い、一つの fit と diagnostics を再利用した。必要な感度分析は研究上の判断と関連づけて案内した。 |
| 表の caption やオブジェクト名だけを表示 | 評価者の推定値、SE、95%区間、適合、信頼性、採点一致率、カテゴリー表と図を実際に表示した。 |
| `DraftReady` や `model_based` を強い主張の根拠と受け取りやすい | データ・モデル・精度・個別の主張の条件を確認するよう説明し、研究全体の完成判定と区別した。 |
| 自動出力が研究目的、募集、訓練、欠測理由などを補うように見える | 15項目の対応表で著者の追記を明示した。モデル選択、bias/DFF、linking、潜在回帰、simulationは研究目的に応じた項目とした。 |
| rater severity、fit、separation reliability、agreement の意味が混ざりやすい | 同じ合成データの具体的数値で、それぞれの対象と解釈を説明した。 |
| 推定値の差をそのまま検定や実用上の影響と捉えやすい | 1.018 logitsの範囲は記述量であり、対比の区間・検定、採点点数差、意思決定への影響ではないことを明示した。 |
| 未定義の追加モデルに依存する例がある | 独立して実行できる既存の比較・専門ヘルプへ案内した。 |
| 参照表を完成した参考文献一覧と誤解しやすい | `chk$references` は略式引用と話題であると説明し、実際に使った方法の完全な書誌、`citation("mfrmr")`、Rの引用・環境情報を確認する例を加えた。 |
| 表示件数の上限が要注意回答の件数・割合にも適用される | 共通計算では全該当行を残し、集計後に表示を制限する処理へ修正した。通常の診断結果とbias補正前後の比較にも適用した。 |

最後の問題は報告値に影響する実装上の不具合だった。例の `abs_z_min = 1.5`、
`prob_max = 0.4`、`rule = "either"` では全282件中141件（50%）が該当する。
従来の `top_n = 10` では要約にも10件（約3.55%）と表示された。
修正後は要約を141件・50%とし、表だけを10件に制限する。
補正前後の比較でも、補正後の表示上限による見かけ上の改善を防ぐ。
推定モデルや推定値の計算は変更していない。

## 参考文献を確認した範囲（初回点検）

初回点検ではZoteroの検索とメタデータ取得のみを行い、ライブラリを変更していない。
以下の3件は**書誌情報と抄録**を読んだ。添付PDF本文の逐項照合はしていないため、
各論文に実際に掲載された表・報告項目の網羅性を確認したとは主張しない。
抄録から、報告ガイドで扱うべき研究目的・採点設計・精度の論点を選ぶ際に参照した。

| 文献 | 今回の点検に関連する論点 |
| --- | --- |
| Goodwin (2016), *A Many-Facet Rasch analysis comparing essay rater behavior on an academic English reading/writing test used for two purposes*. Assessing Writing, 30, 21–31. [DOI](https://doi.org/10.1016/j.asw.2016.07.004) | 同じrubricでも得点利用の目的と研究上の比較を明示する。 |
| Wind, Jones, & Grajeda (2023), *Does sparseness matter? Examining the use of generalizability theory and many-facet Rasch measurement in sparse rating designs*. Applied Psychological Measurement, 47(5–6), 351–364. [DOI](https://doi.org/10.1177/01466216231182148) | 評価者割当と疎な採点設計を明示し、検討する評価者効果と分析を結びつける。 |
| Xiao, Patz, & Wilson (2026), *Revisiting reliability with human and machine learning raters under scoring design and rater configuration in the many-facet Rasch model*. British Journal of Mathematical and Statistical Psychology. [DOI](https://doi.org/10.1111/bmsp.70034) | 採点設計・評価者構成・誤差の種類を踏まえて信頼性の意味を説明する。 |

一般的な報告範囲の根拠には、JARS-Quantの出版社掲載情報と、公開されている
*Standards for Educational and Psychological Testing* の本文（第2章・第7章）を参照した。
対応表はこれらの表の転載ではなく、現行APIと本点検の目的に合わせた整理である。

- Appelbaum et al. (2018). JARS-Quant. [出版社掲載情報](https://doi.org/10.1037/amp0000191)。
  出版社検索で取得できた本文・表の抜粋と書誌情報を使用した。出版社PDFの直接取得は
  アクセス確認画面に阻まれており、全文を取得できたとは扱っていない。
- AERA, APA, & NCME (2014). *Standards for Educational and Psychological Testing*.
  [公式公開本文](https://www.testingstandards.net/uploads/7/6/6/4/76643089/standards_2014edition.pdf)。
  得点の利用・解釈に応じた文書化と精度の根拠、信頼性が表す誤差源を参照した。

## 初回修正の検証

- 2本のvignetteを例の実行あり／実行を省略するビルドの両方でHTML化した。
  表・図が生成され、HTMLに実行エラーや警告の表示がないことを確認した。
  報告ガイドの対応表は15項目、図はWright mapとカテゴリー表示の2点。
- 本文に記載した対象数、計画・欠測件数、31点の積分設定、評価者の推定値・SE・
  区間と範囲、採点一致率、その分母、要注意回答の141件・50%を実行結果と照合した。
- 一時フォルダで両方の保存例を実行し、manifestに記載されたファイルの存在を
  確認した。報告bundleではHTMLの出力も確認した。
- 更新した3つのヘルプ例（reporting/APA guide、reporting checklist、
  unexpected-response table）をそれぞれ独立して実行した。
- 関連11テストファイルの229テスト、1,617アサーションが通過した。
  失敗・エラー・警告・skipは0。追加した回帰テストは、通常表、100行を上限とする
  診断表、bias補正前後の比較について、表示上限と全体集計の分離を確認する。
  `either`/`both`の規則、ゼロ件の場合、補正量ゼロでの件数不変も確認した。
- それに先立つ報告・例ポリシー等の7ファイルでも85テストが通過した。
  上記11ファイルと重複するため、これらを単純合算した件数では報告していない。
- 変更前の構文木と比較し、実行コードの変更は4関数の要注意回答集計に限定される
  ことを確認した。合成データの推定値は変更前と一致した。
- Wright mapとカテゴリー図をPNGでも確認した。冒頭のQuick startと自分のCSVの
  説明は今回の作業開始時の内容を保持し、`git diff --check`も通過した。

実行記録・HTML・数値照合用スクリプト：`/tmp/mfrmr-manuscript-qa/`。
回帰テスト：[test-unexpected-prevalence.R](../../tests/testthat/test-unexpected-prevalence.R)。

## 本文照合の追補（2026-09-13）

ユーザーの継続指示に基づき、今回はGoodwin (2016)、Eckes (2005)、Xiao et al.
(2026) のZotero添付PDFを取得し、研究目的、方法、結果、解釈に関する本文と
主要な表を照合した。GoodwinとEckesは実証研究、Xiaoらはシミュレーションと
実データ応用を含む研究として選定した。ライブラリへの書き込みはしていない。

本文テキストだけでは式・表の配置が崩れるため、次のPDFページを画像でも確認した。
GoodwinはPDF pp. 7, 10（誌面pp. 27, 30）、EckesはPDF pp. 10, 13, 16
（誌面pp. 206, 209, 212）、XiaoらはPDF pp. 6, 15, 17（本文のページ番号と同じ）。
書誌情報だけによる前回点検を、以下の本文の根拠で補った。

### 論文の問い・報告項目と現行出力の対応

| 論文・確認箇所 | 問いと報告の仕方 | 現行mfrmrの対応と補足した説明 |
| --- | --- | --- |
| [Goodwin (2016)](https://doi.org/10.1016/j.asw.2016.07.004), Sections 3–4, Table 1, Appendix B | 入学判定と配置という異なる得点利用で、同じrubricの使い方が異なるかを検討。採点開始時期、採点量、除外、再受験のIDの扱い、カテゴリー統合、test typeの固定とPCM構造を説明する。 | 行数・人数・採点回数を区別し、IDが人物か回答・時点か、採点上の例外と統合規則を記述するよう補った。研究者が採点履歴や除外理由を提供する必要がある。 |
| Goodwin, Section 5, Tables 2–4, Appendix B | 閾値、評価者の位置・SE・適合、評価者×test typeの結果を別々に提示し、最初の採点経験との関係を検討する。 | raterの全体的severityと局所的interactionを同じ意味で扱わない。主張する対比、対象件数、符号、基準、SEの種類を確認する。合成例には採点開始時期のデータがないため、この問いを再現したとはしない。 |
| [Eckes (2005)](https://doi.org/10.1207/s15434311laq0203_2), Method pp. 201–204, Tables 1–2 | 採点者訓練と採点計画を背景に、severity、内部一貫性、interaction等を分けて検討。モデル制約、収束基準、反復回数、各facetの要約を提示し、受験者要約には非極端得点者の注記がある。 | 推定設定と、人数・要約対象者数・EAP分布のSD・平均posterior SDを示した。FACETSの収束基準や非極端得点者への制限を、現行MML例の基準と同一視しない。 |
| Eckes, Global Model Fit p. 204, Table 4 | 標準化残差の絶対値が2以上・3以上の件数と分母、異なるMnSq範囲での評価者割合を示す。 | 現行EAP残差の全件数・評価可能件数・該当数・割合を追加。`unexpected_response_table()`の確率条件を含む既定規則とは区別し、特定割合だけで適合を認定しない。局所的なmarginalの旗も併記した。 |
| Eckes, Table 3, pp. 208–209 | 観測平均と調整平均を、logit measure・SE・採点数と並べ、判断カテゴリーへの影響を説明する。 | `fair_average_table(..., reference = "zero")`の例を追加。FairZの参照条件と得点単位、ModelSEのlogit単位を区別する。RSM/PCMの同テーブルはFairZ自体のSEを供給しない。判断の変化を主張するには実際のcutoffと全対象者の評価が必要。 |
| Eckes, Table 5, p. 212 | criterionごとの閾値とSEを提示する。 | 既存の`diag$parameter_uncertainty$steps`から閾値SE・区間・状態を表示する手順を追加。`rating_scale_table()`への別diagnosticsの指定だけでは、その不確実性列は自動追加されない。PCMではStepFacetを保持する。 |
| [Xiao et al. (2026)](https://doi.org/10.1111/bmsp.70034), Sections 2.4–2.7, Equation 4, Tables 5–6 | 採点密度・評価者構成・固定/自由パラメータ条件と精度を関連づける。モデルに基づくEAP reliabilityと、真値が既知のsimulationの相関二乗を区別し、実データ応用にはSR anchorを用いる。 | 現行`Reliability`の分離信頼性の式を明示し、論文のEAP reliabilityとの取り違えを防いだ。scoring designとanchorの条件が異なる結果を直接比較しない。自動採点にはモデル版、日時、prompt等の研究記録も必要とした。 |

### 論文をそのまま手本にしない点

ここで行ったのは報告の問いと必要情報の照合であり、3論文の実データ解析の再現や、
論文中のすべての推論の妥当性確認ではない。各論文で採用された除外、閾値、
有意性の判断、得点調整を、そのまま推奨規則として追加していない。
例えばEckesのspeaking分析には課題によって異なるカテゴリー数があり、
Xiaoらの分析にはSR anchorがある。単一の1–4 RSM例がこれらの設計まで再現したとはしない。

GoodwinのAppendix BはSeparationとStrataを別々に表示する。現行mfrmrでも
両者の式と列を区別して説明し、どちらも観測された集団数とは表現しない。
XiaoらのEquation 4も、mfrmrの分離信頼性と異なる式である。同じ合成fitに
式4を適用する参考計算では約0.744となり、mfrmrのperson separation reliability
約0.664とは一致しない。これは係数の定義の違いを示す計算で、TAMによる再推定ではない。

また、確認したXiaoらのPDFでは、Wildlife.07のML severityがTable 5の0.25と
Section 3.3.4の0.17で一致していない。今回の記載例には論文の数値を転用せず、
合成例の出力を直接検算した。研究の引用と、出力・本文の数値整合の確認は別の作業である。

### 今回の修正と確認

- 報告vignetteに、合成データの短いMethods/Resultsを追加した。問いとモデルの役割、
  観測数・欠測・採点量、推定条件、結果と不確実性、残る局所診断、解釈の限界をつないだ。
- 閾値SEの取り出し方、観測平均とFairZ、分離信頼性の式、SeparationとStrataの違いを
  既存出力から説明した。新たな推定機能や係数は追加していない。
- 学術論文にあるという理由だけで検定や分析を増やさず、合成例の問いに必要な
  既存出力と、条件付きで使う出力を記述した。
- 自動生成されたAPA本文を元のfitと照合し、2件の実装不整合を修正した。
  facet水準数の整形で先頭の値が再利用され、Criterionの3水準が6水準と表示されていた。
  各facetを個別に整形するよう共通の報告契約を修正した。
  また、報告処理が未実行の残差PCAまで補っていたため、保存済みの診断結果だけを
  再利用するよう共通ヘルパーを修正した。APA本文と図の要約・警告に適用される。
  未指定PCAの本文は省略し、実行済みPCAのエラー情報は保持する。
- 関連8ファイルの193テスト・1,513検証が成功し、失敗・エラー・警告・スキップは0。
  新しい回帰テストは異なるfacet水準数と、残差PCAのnone／overall／facet／bothを
  覆う。計算関数を監視し、報告中の追加PCA計算が0回であること、保存済み結果が
  そのまま使われることも確認した。
- 報告vignetteを`NOT_CRAN=true`で全実行し、`false`の配布用経路でもHTML生成に成功。
  記載例の人数、予定・欠測件数、採点量、平均、推定設定、推定値、SE・区間、
  残差件数、局所的な旗、信頼性の式、カテゴリー頻度、一致率を実出力と照合した。
  修正後の生成文はRater 6水準・Criterion 3水準を示し、PCA結果を含まない。
  `summary(apa)$content_checks`も全9項目で成功した。
- roxygenからヘルプを再生成し、`rating_scale_table`と`mfrmr_reporting_and_apa`の
  Examplesを実行した。今回開始時のR構文との比較で、実行処理の変更は
  `R/reporting.R`に限られ、推定処理には変更がないことを確認した。

今回の本文照合・実行記録：`/tmp/mfrmr-paper-reporting-qa/`。
PDF本文や表画像はこの一時フォルダに留め、パッケージ配布ファイルには追加していない。

## 著者の研究記録から補う情報

研究目的と未解決の問題、参加者・評価者の募集と特性、標本数の根拠、採点者訓練、
rubricと課題の選定理由、割当過程、欠測や除外の理由、仮説・対比と多重性への対応、
倫理・利益相反・資金、データ等の公開条件は、実際の研究に即して記述する必要がある。
これらを得るためだけに不要な追加分析を実行する必要はない。

`build_apa_outputs()` に誤った尺度名を与えても、`summary(apa)$content_checks`
がすべて通る例を確認した。このチェックは生成内容の内部整合を扱い、著者が与えた
研究情報の真偽や、研究の問いに答えたかを判定するものではない。

## 表・図・保存ファイルの整合性点検（2026-09-13）

開発版0.2.4.9000を一時ライブラリにインストールし、`Rscript --vanilla`の
新しいセッションで標準MML/RSM例を実行した。既存オブジェクトを読み込んで
vignetteの実行を代替する方法は採らず、実行後の出力を保存・照合した。
実行記録と画像は`/tmp/mfrmr-output-consistency-qa/`に保存している。

### 確認した不整合と修正

| 箇所 | 確認結果 | 修正 |
| --- | --- | --- |
| 報告・workflow vignetteのWright map | `plot(fit, show_ci = TRUE)`は保存済みMML診断を使わず、観測表の簡易SEを使っていた。R01のSEは図で0.180628、表で0.224352。R02の区間上端も図の約−0.057と表の約0.027で異なっていた。 | 両vignetteで`diagnostics = diag`を渡し、同じ診断に基づく表・図に揃えた。簡易SEの推定処理を変更したわけではない。ステップは図では点推定であり、区間は別表にあることを図注に明示した。 |
| 評価者severity図の補助帯 | `show_bands = FALSE`でもsubtitleと返却legendに補助帯の説明が残った。helpも帯の内側の評価者を運用上交換可能と記述していた。 | 描画と同じ条件で帯の説明・凡例を省略。帯は絶対的なlogit差の表示補助であり、交換可能性や訓練の必要性の判断基準とはしない説明に修正した。 |
| CSVの保存 | 未実行の分析について0行・0列のCSVが書かれ、`read.csv()`が失敗した。results経路では7表、fit bundleのsummary経路では3表に該当。 | results exporterと、fit bundle／summary appendixが共用するsummary writerで列未定義の表を省略。列が定義された0行の表はヘッダーを保存し、未作成ファイルをmanifestに載せない。 |
| 選択した論文用の表・図 | 元の例には表示した表の注記や図を保存する手順がなかった。bundleのAPA文は独自に生成され、別途与えた`context`を引き継がない。 | 未丸めのTable 1 CSV、丸め済みの表・表題・注記TXT、PNGと図注、閾値の不確実性CSV、`context`を含む報告文TXTを明示的に保存した。 |
| 採点計画・欠測と再実行 | fit bundleに`data`を渡さず、再実行スクリプトが`your_data.csv`のままだった。観測データだけでは未観測の予定セルも再構成できない。 | `data = toy`を指定し、採点予定表と予定セルに対する欠測要約も保存。`source(..., chdir = TRUE)`で隣接CSVを読む手順を示した。 |
| results archiveの再実行範囲 | 事前推定fitからの`export_mfrm_results()`のreplayは、`fit`と`diagnostics`が既にあることを前提に結果オブジェクトを再構成するコードだった。 | 元データからの再推定手順との違いをworkflowに明記し、元の分析スクリプトの保存と、データを含むfit bundleへの導線を加えた。新しいreplay APIは追加していない。 |

### 検証範囲

- 標準例は48人、6評価者、3基準、282観測、288予定セル、6欠測。
  表・保存CSV・本文の人数と水準数を確認した。予定欠測とfit時の行除外は区別した。
- Table 1、Wright map、severity profileの評価者推定値・SE・区間端点を
  同じ診断の値と数値比較した。表示用の表は小数3桁、Table 1 CSVは未丸めとして確認した。
- TXTに表題・注記と著者指定のcontextが保存されることを確認した。
  Wright mapと補助帯を非表示にしたseverity図はPNGを目視確認した。
- 121表をCSVと元オブジェクトで照合した（results経路112表、選択表とcore表9表）。
  数値は許容差`1e-12`で確認し、別途、論文用ファイルとfit archiveの全88 CSVが
  読み戻せることも確認した。resultsのstarter exportにplot errorはなかった。
- 報告vignetteは全チャンク実行とCRAN向け非実行経路の両方でHTML生成に成功。
  workflowも新しいRセッションで実行した。
- 元データ入りfit replayを、`fit`も`diagnostics`もない別の`Rscript --vanilla`
  セッションで`source(..., chdir = TRUE)`により実行した。person/facet/stepの
  推定値、対数尤度、全measures、診断モード、readinessが一致した。
  再出力時には既定のデータ取扱い警告が1件出たが、計算・比較の失敗はなかった。
- 関連7テストファイルの141テスト・1,915検証が成功。
  テストの失敗・エラー・警告・スキップは0。roxygenからヘルプを再生成し、
  `git diff --check`も成功した。

この点検は標準例の保存経路と、関連する描画・出力の回帰確認であり、
実データの研究内容や全推定法・全エクスポート構成の同等性を保証するものではない。
