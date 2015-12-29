function skyblock.grow_aerbratus(pos)
	minetest.spawn_tree(pos, {
		axiom   = "TTTTTT&&[a][a][a]",
		rules_a = "dd[B]dd&[b]dd^[b]d[b]",
		rules_b = "TTTTTFFFFFF",
		rules_c = "/",
		rules_d = "/",
		trunk="skyblock:aerbratus_trunk",
		leaves="skyblock:aerbratus_leaves",
		angle=20,
		iterations=2,
		random_level=0,
		trunk_type="single",
		thin_branches=true
	})
end