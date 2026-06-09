// CWDB Critic - Tier B LLM Council.
// Five conflicting lenses analyze independently -> anonymized peer review -> chairman verdict.
// Reserved for high-stakes / uncertain / repeatedly-failing / strategic decisions (the trigger
// logic lives in the orchestrator). Expensive (~11 model calls), so the orchestrator convenes it
// sparingly and counts it against the budget ledger.
//
// Invoke with args = {
//   task_title:   string,
//   dod:          string | string[]      // definition of done
//   output:       any                    // the worker's artifact under review
//   context:      string                 // objective + relevant prior verdicts, pulled from state
//   trigger_reason: string               // why the council was convened
//   high_stakes:  boolean                // is the underlying action irreversible / external-facing
// }
// Returns: { chairman_verdict: 'pass'|'changes'|'escalate', rationale, one_thing_first,
//            advisors: [...], peer_reviews: [...] }   // full record for the event_log audit trail.

export const meta = {
  name: 'cwdb-council',
  description: 'LLM Council critic for a CWDB control-loop task output: 5 conflicting lenses, anonymized peer review, chairman synthesis into a binding verdict.',
  phases: [
    { title: 'Advisors', detail: '5 independent lenses analyze the output in parallel' },
    { title: 'Peer review', detail: 'anonymized cross-review (kills identity/position bias)' },
    { title: 'Chairman', detail: 'binding pass / changes / escalate verdict' },
  ],
}

const input = args || {}
const dod = Array.isArray(input.dod) ? input.dod.map((d, i) => `  ${i + 1}. ${d}`).join('\n') : String(input.dod || '(none provided)')
const output = typeof input.output === 'string' ? input.output : JSON.stringify(input.output, null, 2)
const ctx = input.context || '(no extra context)'
const highStakes = !!input.high_stakes

const BRIEF = `## Task under review
${input.task_title || '(untitled)'}

## Definition of done
${dod}

## The output being judged
${output}

## Context (objective + prior council history on this lineage - do not re-litigate settled ground)
${ctx}

## Why this council was convened
${input.trigger_reason || '(unspecified)'}
`

const LENSES = [
  { key: 'contrarian', name: 'Contrarian',
    lens: 'Hunt for the FATAL FLAW. What is wrong, missing, or will fail in this output? Assume it is broken and find where. Do not hedge or balance - your job is the strongest possible case against shipping it.' },
  { key: 'first_principles', name: 'First Principles',
    lens: 'Ignore the surface task. Ask whether this output solves the ACTUAL problem - or whether the task itself is mis-framed. Reason from the underlying goal (maximize qualified leads, then accepted bids), not from the literal instruction.' },
  { key: 'expansionist', name: 'Expansionist',
    lens: 'Look for upside left on the table. Is this output UNDERAMBITIOUS relative to the goal? What bigger, higher-leverage version was within reach and skipped?' },
  { key: 'outsider', name: 'Outsider',
    lens: 'You have ZERO project context. React only to what is literally in front of you, as the recipient (a homeowner or contractor) would. Catch the curse of knowledge - anything confusing, unclear, or off to a fresh reader.' },
  { key: 'executor', name: 'Executor',
    lens: 'Only one question: is this SHIPPABLE right now, and if not, what is the single concrete next step? No theory. Decision + the one action.' },
]

phase('Advisors')
const advisorRaw = await parallel(LENSES.map((l) => () =>
  agent(
    `You are the **${l.name}** advisor on a review council. Lean fully into your angle; do not soften or balance it - the council gets diversity from each advisor being one-sided.\n\n${l.lens}\n\n${BRIEF}\n\nWrite 150-300 words. No preamble, no restating the task. Just your analysis through your lens.`,
    { label: `advisor:${l.key}`, phase: 'Advisors' }
  ).then((text) => ({ key: l.key, name: l.name, text }))
))
const advisors = advisorRaw.filter(Boolean)

// Anonymize: strip lens identity, relabel A.. by a deterministic rotation (no Math.random in workflows).
const rot = (String(input.task_title || '').length) % (advisors.length || 1)
const anon = advisors.map((a, i) => ({ letter: String.fromCharCode(65 + ((i + rot) % advisors.length)), text: a.text, _key: a.key }))
  .sort((x, y) => x.letter.localeCompare(y.letter))
const anonBlock = anon.map((a) => `### Reviewer ${a.letter}\n${a.text}`).join('\n\n')

phase('Peer review')
const peerRaw = await parallel(anon.map((a) => () =>
  agent(
    `Five anonymous reviewers analyzed the same output below. You are one of them (you do not know which). Read all five.\n\n${anonBlock}\n\nReturn three things, briefly: (1) which reviewer made the STRONGEST take and why; (2) the single biggest BLIND SPOT across all five; (3) what they ALL missed. Be specific. 120-200 words.`,
    { label: `peer:${a.letter}`, phase: 'Peer review' }
  ).then((text) => ({ letter: a.letter, text }))
))
const peerReviews = peerRaw.filter(Boolean)

phase('Chairman')
const deAnon = advisors.map((a) => `### ${a.name}\n${a.text}`).join('\n\n')
const peerBlock = peerReviews.map((p) => `### Peer review (was Reviewer ${p.letter})\n${p.text}`).join('\n\n')

const VERDICT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['chairman_verdict', 'rationale', 'one_thing_first'],
  properties: {
    chairman_verdict: {
      type: 'string', enum: ['pass', 'changes', 'escalate'],
      description: "pass = converged, ship/commit. changes = requeue with one_thing_first as the only feedback. escalate = genuine high-stakes clash among reasonable advisors -> a human must decide.",
    },
    rationale: { type: 'string', description: 'Why this verdict. May overrule the advisor majority if the dissent is strongest - say so explicitly if you do.' },
    one_thing_first: { type: 'string', description: "The single most important concrete next step. For 'changes' this becomes the ONLY requeue feedback." },
    high_stakes_clash: { type: 'boolean', description: 'True if reasonable advisors genuinely disagree AND the action is irreversible/external-facing.' },
  },
}

const verdict = await agent(
  `You are the **Chairman** of the review council. You receive the five advisors (de-anonymized) and their peer reviews. Synthesize a single binding verdict.\n\n` +
  `This action is ${highStakes ? 'HIGH-STAKES (irreversible / external-facing)' : 'low-stakes (reversible/internal)'}.\n\n` +
  `Rules: Converged + no high-stakes clash -> 'pass'. Recommends changes -> 'changes' (your one_thing_first is the only feedback that will be sent back). Genuine clash among reasonable advisors on a high-stakes action -> 'escalate' (a human decides; council conflict is the signal we WANT surfaced). You MAY overrule the majority if the dissenting reasoning is strongest - state that in the rationale.\n\n` +
  `## Advisors\n${deAnon}\n\n## Peer reviews\n${peerBlock}\n\n${BRIEF}`,
  { label: 'chairman', phase: 'Chairman', schema: VERDICT_SCHEMA }
)

return {
  chairman_verdict: verdict.chairman_verdict,
  rationale: verdict.rationale,
  one_thing_first: verdict.one_thing_first,
  high_stakes_clash: !!verdict.high_stakes_clash,
  advisors,
  peer_reviews: peerReviews,
}
