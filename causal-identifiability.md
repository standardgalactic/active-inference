# Transcription Error and Causal Identifiability

## A Case Study in Generated Lectures and Speech Recognition

An audio-generation system produces a spoken performance from source material. A speech-recognition system subsequently attempts to reconstruct its linguistic content.

When the resulting transcript contains errors, those discrepancies do not uniquely identify the mechanism responsible.

This problem becomes especially visible when a generated lecture repeatedly misrepresents unfamiliar names, technical vocabulary, or philosophical terminology.

## The Production and Recognition Pipeline

Let \(T\) denote the intended linguistic sequence, \(G\) a speech-generation process, \(A\) the generated acoustic signal, and \(R\) a speech-recognition process.

The observable pipeline is

\[
T\xrightarrow{G}A\xrightarrow{R}\widehat T.
\]

The resulting discrepancy can be measured by

\[
E(T)=d(T,\widehat T)
=d(T,R(G(T))),
\]

where \(d\) is an appropriate textual distance measure.

This discrepancy establishes that the composed transformation did not preserve the intended representation under the chosen metric.

It does not establish whether the error originated in the generator, the recognizer, or their interaction.

## Non-Identifiability

Suppose the intended expression is the proper name *Flyxion*, but the resulting transcript contains *affliction*.

Several explanations remain possible.

The speech generator may have produced a pronunciation that resembled the ordinary word. Alternatively, it may have produced a recognizable pronunciation of the proper name that the speech recognizer mapped onto a more probable lexical candidate. Both processes may also have contributed.

The observation

\[
R(G(T))\neq T
\]

does not identify which component failed.

More generally, different pairs of generating and recognizing mechanisms may produce the same observable transcript:

\[
R_1(G_1(T))=R_2(G_2(T)),
\]

despite differing substantially in their internal behavior.

The causal explanation is therefore underdetermined by the final transcript alone.

## Lexical Priors and Unfamiliar Names

Speech recognition can be understood approximately as inference over candidate linguistic sequences:

\[
P(T\mid A,C)
\propto
P(A\mid T,C)P(T\mid C),
\]

where \(C\) represents linguistic context.

This Bayesian expression is a conceptual model of recognition, not a claim that Whisper explicitly computes these factors.

When a proper name is uncommon in the recognizer's training distribution, familiar alternatives may receive greater probability.

The resulting substitutions can be grammatically plausible while being referentially incorrect.

This distinction matters because syntactic fluency is not evidence of correct attribution.

## A Personalized Correction Vocabulary

An existing transcription workflow uses a growing collection of observed variants of the name *Flyxion*.

Examples include *Flixion*, *Flaxen*, *Phlyoxian*, and numerous other phonetic approximations or substitutions.

A deterministic normalization process maps established variants to the intended name. Ambiguous ordinary words, including *friction*, *fiction*, *infliction*, and *affliction*, are subjected to interactive classification.

This creates two distinct operations:

\[
N(w)=\text{automatic normalization},
\]

for established variants, and

\[
J(w,c)=\text{contextual adjudication},
\]

for ambiguous occurrences requiring a decision about the intended reference.

The process is intentionally narrow. It is not designed to repair every transcription error.

## Amortization of Correction

Let \(c_i\) denote the human cost of recognizing and adjudicating an unfamiliar variant \(v_i\). Once the correction has been incorporated into a reusable vocabulary, subsequent occurrences may be processed at much lower marginal cost.

If the variant occurs \(n_i\) times, the average human correction cost per occurrence is approximately

\[
\overline c_i
=
\frac{c_i+m_i}{n_i},
\]

where \(m_i\) represents any subsequent maintenance and review costs.

When \(m_i\) grows slowly relative to \(n_i\), the average cost declines with reuse.

This is a small practical instance of amortized deliberation: a human classification decision becomes a reusable computational operation.

It does not imply that all future occurrences are correctly classified. False positives remain possible, especially when candidate spellings are also legitimate ordinary words or names.

## Provenance Preservation

A stronger production system would expose the linguistic representation associated with generated speech.

Rather than requiring users to infer the spoken script from the audio, it could provide a synchronized record of generated utterances.

Such a record need not be a preexisting immutable script. It could be assembled during generation and preserved as an output artifact.

The essential requirement is that the representation be causally connected to the generation process rather than reconstructed independently afterward.

This would make it possible to distinguish discrepancies between source documents and generated narration from discrepancies between generated narration and recognized transcription.

## Experimental Protocol

A useful evaluation would preserve the source text, generated audio, automatic transcript, and manually adjudicated corrections.

For selected utterances, independent human listeners could transcribe the audio without seeing the source material.

The experiment could then compare recognition accuracy for familiar vocabulary, unfamiliar names, technical expressions, and ambiguous ordinary words.

Repeated occurrences of the same name would permit investigation of contextual variation, although repeated tokens within the same recording would not constitute independent experimental trials.

Error categories should distinguish substitution, deletion, insertion, incorrect attribution, and grammatical deformation.

Human transcription would provide additional evidence about intelligibility but would not, by itself, establish the internal cause of every discrepancy.

## Relation to Active Inference and Predictive Processing

The problem illustrates the interaction between incoming evidence and learned expectations.

An unfamiliar expression may be interpreted through a familiar lexical hypothesis when the available acoustic evidence does not sufficiently distinguish the alternatives.

This resembles a general predictive-processing problem: prior expectations influence the interpretation of ambiguous observations.

However, the analogy should not be mistaken for evidence that a particular speech recognizer implements a specific active-inference architecture.

The empirical issue is how contextual expectations and acoustic information interact in determining the recognized sequence.

## Conclusion

Transcription errors reveal discrepancies in an information-processing pipeline, but their causes cannot generally be identified from the final transcript alone.

A personalized correction vocabulary can reduce recurring errors by converting historical human judgments into reusable computational rules.

The broader architectural lesson concerns provenance. Systems that generate complex artifacts should preserve sufficient intermediate information to permit verification, correction, and reproducible transformation.

---

*Research note, October 2026.*
