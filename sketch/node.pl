use strict;
use warnings;
use Node;

for (1..1#0000
) {
my $doc = new Document;
 
#my $dom = $doc->implementation;

my $el = $doc->create_element ('a');
my $el2 = $doc->create_element ('b');
my $el3 = $doc->create_element ('c');

warn $doc;
warn my $od = $el->owner_document;

$doc->append_child ($el);
$el->append_child ($el2);
$el2->append_child ($el3);
eval {
$el2->append_child ($doc);
};
warn $@;

warn $el->parent_node;

warn $el;
warn $doc->first_child;
warn $el2->parent_node;

warn $el2;
warn $el->first_child;

my $list1 = $doc->get_elements_by_tag_name ('b');
warn $list1;
warn $list1->length;
my $list2 = $doc->get_elements_by_tag_name ('b');
warn $list2;
warn $list2->length;
warn $list2->item (0);
warn $list2->item (0)->local_name;

$el->remove_child ($el2);
undef $el2;
undef $el3;

warn $el->first_child || 0;

throw HierarchyRequestError;

#use Data::Dumper;
#warn Dumper $el;
}
