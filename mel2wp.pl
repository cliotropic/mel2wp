#!/usr/bin/perl -w

# MellelTranslate.pl version 0.1
#  a text-cleanup filter to speed conversion of endnoted Mellel documents into WordPress blog posts.
#
# For usage and known bugs, see the attached README.
# 
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use Carp;

my $f = $ARGV[0];
unless ($f) { print "Please give a single filename as an argument.\n" and die;}

$/ = "";  # Turn slurp mode on; don't break searches at \n newlines.

my $text = read_file( $f ) ;

my $i = 1;
while ($i >= 0) {
	# Notice that footnote marks in text and before the actual endnote are the same, 
	# and take advantage of that. Using a loop, look for the notes in numerical 
	# sequence.
	my $mark = '\*\*' . $i . '\*\*';  # How to recognize a footnote.
	
	# Look for an endnote marker and its related endnote. The marker goes in $1; 
	# the note itself goes in $3; the text between them goes in $2.
	# Replace the original endnote marker with the note, encased in square brackets.
	if ($text =~ s:($mark)(.*)$mark ([^\n]+)\n:[$i. $3]$2:s) {
		$i++;
	} else {
		# If the search failed, we're probably looking at the final note.
		# The last footnote won't have a newline after it, so do a modified
		# version of the search, then clean up and drop out of the loop.
		
	    $text =~ s:($mark)(.*)$mark ([^\n]+):[$i. $3]$2:s;
	    # Delete the "Notes" bit at the end.
	    $text =~ s:Notes\n::s;
		$i = -1;
	}
}
print $text;

# from File::Slurp, pasted here for convenience

sub read_file
{
    my ($file) = @_;

    local($/) = wantarray ? $/ : undef;
    local(*F);
    my $r;
    my (@r);

    open(F, "<$file") || croak "open $file: $!";
    @r = <F>;
    close(F) || croak "close $file: $!";

    return $r[0] unless wantarray;
    return @r;
}