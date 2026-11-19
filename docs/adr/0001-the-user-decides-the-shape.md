# The user decides the shape, and the agent finds the facts

Every question with more than one defensible answer is put to the user, with the agent's recommended answer beside it. The agent never settles such a question alone, whereas finding a fact (what the code does, what an API returns, what a library supports) is always the agent's job and never the user's. An agent that meets a question no recorded decision answers stops and asks, during planning and building alike.

Grilling is how this happens. The `grill` skill interviews the user in rounds, each round asking every question whose prerequisites are already settled, and its first step maps the idea onto the concepts the project already has, so that anything new is presented as a deviation with its reason. It ends with a challenge of the plan, whose findings are its last round, so they reach the user.

## Why

An agent that plans alone answers shape questions from inside its own framing, and a reviewer who reads the plan afterwards takes that framing as given. A planner given a job board reached through a JSON API specified a separate workflow with its own queues, although the project's existing abstraction (scrape a board, learn its parsing rules, integrate them) covered both kinds of board. An adversarial review of the plan existed and did not stop it, because the review reported to the planner rather than to the person who owned the abstraction.

Every such question is asked, because an agent is rarely unsure about a shape it has just invented, so its own doubt does not tell which questions matter.

The cost of a wrong shape grows with every step built on it. A question answered in conversation costs a minute, whereas the same question answered by a revert costs a round of implementation and review.
