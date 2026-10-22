# Generative Audio as Compression

## From Waveform Preservation to Executable Linguistic Representation

A conventional audio recording stores a representation of an acoustic event. A generative audio archive instead stores sufficient instructions to produce an acceptable realization of a linguistic performance. The distinction is between preserving a particular signal and preserving a specification from which a family of signals can be generated.

Let \(A\) denote a recorded waveform, \(T\) its linguistic content, \(P\) its pronunciation and prosodic instructions, and \(G_\theta\) a speech-generation model with parameters \(\theta\). The reconstructed recording is

\[
\widehat A=G_\theta(T,P).
\]

The representation \(P\) may contain speaker identities, phonetic overrides, emphasis, pauses, intonation, timing, and other performance constraints. A practical implementation would also require a synthesis environment, model version, and any speaker-conditioning data.

## Compression and Decoder Cost

Suppose the conventional compressed audio requires \(L(A)\) bits. The generative representation requires approximately

\[
L_{\mathrm{gen}}
=
L(T)+L(P)+L(\theta_{\mathrm{ref}}),
\]

where \(\theta_{\mathrm{ref}}\) identifies a previously available synthesis model.

The apparent compression ratio is

\[
C=\frac{L(A)}{L_{\mathrm{gen}}}.
\]

For an hour-long recording at 96 kbps, the audio payload occupies approximately 43.2 MB. A written transcript may occupy only tens of kilobytes, although pronunciation, performance instructions, speaker conditioning, and synchronization metadata increase its size.

This comparison assumes that the synthesis model is already available. If the archive must preserve a self-contained decoder, the model weights, dependencies, and execution environment must also be counted.

Consequently, the compression advantage depends on the accounting boundary and the availability of shared generative infrastructure.

## Semantic Rate-Distortion

Traditional lossy compression minimizes a measure of signal distortion subject to a rate constraint. Generative linguistic compression requires a different distortion function.

Let

\[
D(A,\widehat A)
=
\lambda_sD_s+
\lambda_pD_p+
\lambda_tD_t+
\lambda_vD_v,
\]

where \(D_s\) measures semantic discrepancies, \(D_p\) pronunciation discrepancies, \(D_t\) temporal and prosodic discrepancies, and \(D_v\) speaker-identity discrepancies.

The weights \(\lambda_i\) represent the importance assigned to each dimension. These quantities require operational definitions before the expression can serve as an empirical evaluation metric.

The corresponding optimization problem is

\[
\min_{T,P} L(T)+L(P)
\]

subject to

\[
D(A,G_\theta(T,P))\leq\varepsilon.
\]

Unlike waveform reconstruction, the objective need not be acoustic identity. It may be the preservation of intelligible content and specified performance properties.

## Admissible Realizations

An alternative formulation defines the set

\[
\mathcal A(T,P)
=
\{A': A'\text{ satisfies the constraints encoded by }T,P\}.
\]

A valid reconstruction requires

\[
\widehat A\in\mathcal A(T,P).
\]

This representation permits multiple acceptable realizations of the same lecture, potentially with different voices, playback speeds, or accessibility adaptations.

However, membership in the admissible set must be determined by explicit criteria. Semantic equivalence, phonetic accuracy, and conversational continuity cannot simply be assumed.

## Local Editing and Regeneration

The most important practical advantage is not necessarily the compression ratio but the possibility of editing the generative specification.

Suppose a lecture is represented as a sequence of segments,

\[
T=(T_1,\ldots,T_n),
\]

with corresponding performance instructions

\[
P=(P_1,\ldots,P_n).
\]

A correction to segment \(T_i\) should ideally require regenerating only a limited neighborhood of the original performance:

\[
\widehat A_{i-k:i+k}
=
G_\theta(T_{i-k:i+k},P_{i-k:i+k}).
\]

The regeneration window \(k\) must be sufficiently large to preserve continuity of prosody, timing, and speaker identity.

A robust implementation would distinguish textual edits from performance edits and preserve synchronization information across revisions.

## Relation to Amortized Deliberation

A finished lecture embodies linguistic, editorial, and performative decisions made during its production. Conventional audio preserves the acoustic result but does not necessarily expose those decisions as editable objects.

A generative representation preserves some of the decisions in executable form, allowing subsequent revisions without repeating the entire production process.

In this sense, the specification functions as a compiled representation of earlier deliberation. Its utility depends on how much of the original production process can be reused rather than recomputed.

## Open Questions

The proposal leaves several unresolved questions concerning deterministic reconstruction, model availability, archival durability, speaker consistency, local regeneration, and the measurement of semantic distortion.

A central empirical question is whether the storage savings and editing advantages remain substantial after accounting for pronunciation instructions, synthesis dependencies, and verification costs.

The distinction between acoustic preservation and generative reconstruction must remain explicit. A generative archive can preserve a lecture's intended linguistic performance without preserving the historically original recording.

---

*Research note, October 2026.*
