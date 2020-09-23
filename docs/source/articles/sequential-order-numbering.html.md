---
title: Sequential Order Numbering
created_at: 2020/09/24
excerpt: "Why Workarea's orders are not sequential and numerical, as well as some tips on how one might do this in their own application."
---

# Sequential Order Numbering

When an order is created or instantiated, it is assigned a randomized 5-digit uppercase hexadecimal value as its ID. Workarea does this so order numbers are legible to human eyes, and will play nicely on a distributed database system such as MongoDB. This ID is used throughout the system to link orders to their Payment and Shipping information, as well as in the admin for display purposes. Some clients may want this display ID to be sequentially numbered, which is possible to customize, but we strongly advise against it. MongoDB is a distributed database, so in production there are many instances of Mongo running to make sure that your app's data is not only within reach, but can be retrieved efficiently. This can lead to gaps in the order numbers, as well as order numbers appearing out of order in the admin (since Workarea only shows you orders which have been placed).

If you do wish to customize this, however, we advise using the [Mongoid::Autoinc](https://github.com/suweller/mongoid-autoinc) plugin and decorating Order like so:

```ruby
module Workarea
  decorate Order do
    decorated do
      include Mongoid::Autoinc

      field :number, type: Integer, default: 0

      increments :number
    end
  end
end
```

You will probably also want to decorate places in the admin where this number would appear, such as the orders index page:

```diff
diff --git a/admin/app/views/workarea/admin/orders/index.html.haml b/admin/app/views/workarea/admin/orders/index.html.haml
index c6c4cb7d4e..d00f9f67de 100644
--- a/admin/app/views/workarea/admin/orders/index.html.haml
+++ b/admin/app/views/workarea/admin/orders/index.html.haml
@@ -87,6 +87,7 @@
                 = check_box_tag 'select_all', nil, false, id: 'select_all', class: 'checkbox__input', data: { bulk_action_select_all: '' }
                 = label_tag 'select_all', t('workarea.admin.bulk_actions.select_all'), class: 'checkbox__label'
             %th= t('workarea.admin.fields.id')
+            %th= t('workarea.admin.fields.number')
             %th= t('workarea.admin.fields.email')
             %th.align-right= t('workarea.admin.fields.total_price')
             %th= t('workarea.admin.fields.payment_status')
@@ -102,6 +103,7 @@
                   = label_tag dom_id(result), '', class: 'checkbox__label', title: t('workarea.admin.bulk_actions.add_summary_button')
               %td
                 = link_to result.id, order_path(result)
+                = result.number
                 = comments_icon_for(result)
                 = fraud_icon_for(result)
                 = append_partials('admin.order_index_icons', result: result)
```

However you wish to do this is up to you (and your client). The main goal here is to allow the sequential order numbering to live adjacent to the way orders are identified in the system. This is the most frictionless way to achieve what your admins are looking for, even though it may result in a duplicate number from time to time given a high level of traffic (such as thousands of orders per minute).

We still recommend working with your client to help them understand why Workarea's order IDs look the way they do, but if they push back enough, then using the above tips should allow you to make them happy without jeopardizing the performance of your application.
