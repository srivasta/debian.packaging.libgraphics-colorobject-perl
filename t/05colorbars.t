use Test::More tests => 801;
BEGIN { use_ok('Graphics::ColorObject') };

foreach $s1 (&Graphics::ColorObject::list_colorspaces())
{
	foreach $s2 (&Graphics::ColorObject::list_colorspaces())
	{
		foreach $rgb (
					  [1, 1, 1],
					  [1, 1, 0],
					  [0, 1, 1],
					  [0, 1, 0],
					  [1, 0, 1],
					  [1, 0, 0],
					  [0, 0, 1],
					  [0, 0, 0]
					  )
		{
			$rgb = &Graphics::ColorObject::_mult_m33_v3([[3/4,0,0],[0,3/4,0],[0,0,3/4]], $rgb);
			#&roundtrip_convert($rgb, $s1, $s2);
			ok( &roundtrip_convert($rgb, $s1, $s2), "$s1 -> $s2 -> $s1" );
		}
	}
}

sub roundtrip_convert
{
	my ($rgb, $s1, $s2) = @_;
	my ($c1, $c2, $c1_copy, $rgb_copy);

	# eval is only used here to save writing out a whole lot of code by hand
	# we don't really want to trap fatal errors
	eval '$c1 = Graphics::ColorObject->new_RGB($rgb, space=>"NTSC")->as_'.$s1.'()';         # rgb -> s1
	if ($@) { print STDERR "\n failed with fatal error: RGB -> $s1 : $@ \n"; return 0; };
	eval '$c2 = Graphics::ColorObject->new_'.$s1.'($c1, space=>"NTSC")->as_'.$s2.'()';      # s1 -> $s2
	if ($@) { print STDERR "\n failed with fatal error: $s1 -> $s2 : $@ \n"; return 0; };
	eval '$c1_copy = Graphics::ColorObject->new_'.$s2.'($c2, space=>"NTSC")->as_'.$s1.'()'; # s2 -> $s1
	if ($@) { print STDERR "\n failed with fatal error: $s2 -> $s1 : $@ \n"; return 0; };
	eval '$rgb_copy = Graphics::ColorObject->new_'.$s2.'($c2, space=>"NTSC")->as_RGB()';    # s2 -> rgb
	if ($@) { print STDERR "\n failed with fatal error: $s2 -> RGB : $@ \n"; return 0; };
	my $result = (&Graphics::ColorObject::_delta_v3( $rgb, $rgb_copy ) < 0.000005);
	#(&Graphics::ColorObject::_delta_v3( $c1, $c1_copy ) < 0.001 * ($c1->[0]+$c1->[1]+$c1->[3]));

	#print STDERR "$s1 -> $s2 -> $s1 : ", ($result  ? 'ok' : 'not ok'), "\n";
	if (! $result)
	{
		print STDERR "\n roundtrip conversion failed : $s1 -> $s2 -> $s1 : ";
		print STDERR "rgb=[ $rgb->[0], $rgb->[1], $rgb->[2] ] -> ";
		print STDERR "$s1=[ $c1->[0], $c1->[1], $c1->[2] ] -> ";
		print STDERR "$s2=[ $c2->[0], $c2->[1], $c2->[2] ] -> ";
		print STDERR "$s1=[ $c1_copy->[0], $c1_copy->[1], $c1_copy->[2] ]";
		print STDERR "\n";
	}

	return $result;
}
