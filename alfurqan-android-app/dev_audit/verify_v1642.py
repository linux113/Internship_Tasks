#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""v1.6.42+71 (22/09) — LOGIC-MIRROR micro-tests. Dart logic ka python-me
mirror, kyunki sandbox me Flutter/Dart SDK nahi hai. Har test bilkul wahi
data-use karta hai jo Lalit ne report kiya:

 POINT 1 & 5 (timeline me SAME status DO baar, do alag dates)
 POINT 4    (3 products wale order ka history placeholder / galat qty)

Run: python3 verify_v1642.py   (exit 0 = sab PASS)
"""
import sys

FAIL = []

def check(name, cond):
    print(('PASS ' if cond else 'FAIL ') + name)
    if not cond:
        FAIL.append(name)

# ---------- canonical status key (order_detail_controller.dart mirror) ----------
def canon(raw):
    l = (raw or '').strip().lower().replace(' ', '_')
    if not l: return ''
    if 'cancel' in l: return 'cancelled'
    if 'out' in l and 'deliver' in l: return 'outForDelivery'
    if 'deliver' in l and 'undeliver' not in l: return 'delivered'
    if 'ship' in l or 'dispatch' in l: return 'shipped'
    if 'process' in l or 'progress' in l or 'confirm' in l or 'pack' in l: return 'processing'
    if 'pend' in l or 'place' in l or 'new' in l or 'order' in l: return 'pending'
    return ''

# ---------- POINT 1/5: activity cleaner (name-less drop + same-name dedupe) ----------
def clean_activities(acts):
    """acts: [{'name','note','date'}] chronological sorted. Mirror of the
    timeline.removeWhere block."""
    out, placement, seen = [], None, set()
    for t in acts:
        nm, note, dt = (t.get('name') or '').strip(), (t.get('note') or '').strip(), (t.get('date') or '').strip()
        if nm == '':
            if placement is None and dt:
                placement = dt
            if note == '':
                continue  # placement noise dropped
            out.append(t); continue
        k = nm.lower()
        if k in seen:
            continue  # duplicate status event dropped
        seen.add(k)
        out.append(t)
    return out, placement

# POINT 1: admin ne delivered kiya — placement row + 2 delivered activities
acts = [
    {'name': '', 'note': '', 'date': '2026-09-18T10:00:00'},          # placement (null status)
    {'name': 'Delivered', 'note': '', 'date': '2026-09-18T10:00:00'},  # server ne placement-time pe ek likha
    {'name': 'Delivered', 'note': '', 'date': '2026-09-21T16:40:00'},  # admin ne abhi mark kiya (SAHI time)
]
out, placement = clean_activities(acts)
check('P1: duplicate delivered activities -> sirf 1 bachi', sum(1 for a in out if a['name'] == 'Delivered') == 1)
check('P1: name-less placement row drop hui', all(a['name'] != '' for a in out))
check('P1: placement date preserve (pending step ke liye)', placement == '2026-09-18T10:00:00')
kept = [a for a in out if a['name'] == 'Delivered'][0]
check('P1: earliest delivered event rakha (pehla real event)', kept['date'] == '2026-09-18T10:00:00')

# POINT 5: process-status — placement + Processing(real date) -> ek hi row, sahi date
acts = [
    {'name': '', 'note': '', 'date': '2026-09-20T09:15:00'},
    {'name': 'Processing', 'note': '', 'date': '2026-09-20T14:30:00'},
]
out, placement = clean_activities(acts)
check('P5: Processing sirf EK baar (order-date wali copy nahi)', [a['name'] for a in out] == ['Processing'])
check('P5: Processing ka date SAHI (order date par nahi)', out[0]['date'] == '2026-09-20T14:30:00')

# name-less activity NOTE wali ho to rakha jaye (koi asli event ho to)
acts = [
    {'name': '', 'note': 'Order placed by customer', 'date': '2026-09-20T09:15:00'},
    {'name': 'Processing', 'note': '', 'date': '2026-09-20T14:30:00'},
]
out, placement = clean_activities(acts)
check('P5: note wali name-less activity rakhi gayi', len(out) == 2)

# ---------- POINT 1/5: flow-step dedupe by canonical key ----------
def low(s): return (s or '').strip().lower()
def matches(a, b):
    a, b = low(a), low(b)
    if not a or not b: return False
    return a == b or a in b or b in a

def dedupe_flow(steps, status, activities):
    """steps: [{'name','sequence','id'}] -> mirror of flowSteps builder."""
    flow, by_key = [], {}
    def has_act(s):
        return any(matches(a.get('name',''), s['name']) for a in activities)
    for s in steps:
        nm = s['name']
        if not nm: continue
        k = canon(nm)
        if k == '':
            flow.append(s); continue
        if k not in by_key:
            by_key[k] = len(flow); flow.append(s); continue
        i = by_key[k]
        prev = flow[i]
        prev_exact = low(prev['name']) == low(status)
        new_exact = low(nm) == low(status)
        prev_act, new_act = has_act(prev), has_act(s)
        if (new_exact and not prev_exact) or (new_act and not prev_act and not prev_exact):
            flow[i] = s
    return flow

# Delivery + Delivered dono steps (same canonical key) — delivered current
steps = [
    {'name': 'Pending', 'sequence': 1, 'id': 1},
    {'name': 'Processing', 'sequence': 2, 'id': 2},
    {'name': 'Delivery', 'sequence': 5, 'id': 5},
    {'name': 'Delivered', 'sequence': 6, 'id': 6},
    {'name': 'Cancelled', 'sequence': 9, 'id': 9},
]
activities = [{'name': 'Delivered', 'note': '', 'date': '2026-09-21T16:40:00'}]
flow = dedupe_flow(steps, 'Delivered', activities)
deliv = [s['name'] for s in flow if canon(s['name']) == 'delivered']
check('P1: flow me delivered-family sirf EK step (do delivered rows nahi)', len(deliv) == 1)
check('P1: behtar step chuna gaya (Delivered — exact current match)', deliv == ['Delivered'])

# Ready to ship + Shipped (same canonical 'shipped'): activity Shipped wala
steps = [
    {'name': 'Pending', 'sequence': 1, 'id': 1},
    {'name': 'Ready to ship', 'sequence': 3, 'id': 3},
    {'name': 'Shipped', 'sequence': 4, 'id': 4},
]
flow = dedupe_flow(steps, 'Shipped', [{'name': 'Shipped', 'note': '', 'date': 'x'}])
ship = [s['name'] for s in flow if canon(s['name']) == 'shipped']
check('P5: shipped-family dedupe — activity wala step chuna', ship == ['Shipped'])

# ---------- POINT 4: history placeholder rebuild ----------
def rebuild_history(cur_rows, real_items):
    """cur_rows: [{'name','image','qty','size',...}] single-order card rows.
    real_items: [{'name','image','qty'}] detail se. Mirror of Step 3b."""
    if not real_items: return cur_rows, False
    is_placeholder = len(cur_rows) == 1 and (
        cur_rows[0]['name'].startswith('Order #') or not cur_rows[0]['image'])
    changed = False
    if is_placeholder or len(cur_rows) != len(real_items):
        keep = cur_rows[0]
        new = []
        for k, it in enumerate(real_items):
            new.append({
                'image': it['image'],
                'name': it['name'] or keep['name'],
                'size': keep['size'] if k == 0 else '',
                'qty': it['qty'] if isinstance(it['qty'], int) else 1,
                'date': keep.get('date','',), 'status': keep.get('status',''),
            })
        return new, True
    for k in range(len(cur_rows)):
        q = real_items[k].get('qty')
        if isinstance(q, int) and q > 0 and cur_rows[k]['qty'] != q:
            cur_rows[k]['qty'] = q; changed = True
    return cur_rows, changed

# 3 products ek saath — slim row se single placeholder qty=1 bana tha
cur = [{'name': 'Order #1102', 'image': '', 'qty': 1, 'size': '84.60', 'date': '2026-09-20', 'status': 'Processing'}]
real = [
    {'name': 'تفسير ابن كثير', 'image': 'media/book1.jpg', 'qty': 2},
    {'name': 'Sahih Muslim', 'image': 'media/book2.jpg', 'qty': 1},
    {'name': 'رياض الصالحين', 'image': 'media/book3.jpg', 'qty': 1},
]
rows, changed = rebuild_history([dict(cur[0])], real)
check('P4: placeholder row -> 3 asli item rows', len(rows) == 3 and changed)
check('P4: har row ka asli naam', [r['name'] for r in rows] == ['تفسير ابن كثير', 'Sahih Muslim', 'رياض الصالحين'])
check('P4: har row ki ASLI qty (2/1/1 — 1/1/1 nahi)', [r['qty'] for r in rows] == [2, 1, 1])
check('P4: total sirf FIRST row par', rows[0]['size'] == '84.60' and rows[1]['size'] == '' and rows[2]['size'] == '')
check('P4: date/status preserve', all(r['date'] == '2026-09-20' and r['status'] == 'Processing' for r in rows))

# count match par sirf qty sync
cur = [
    {'name': 'تفسير ابن كثير', 'image': 'media/book1.jpg', 'qty': 1, 'size': '60.00', 'date': 'd', 'status': 'Pending'},
    {'name': 'Sahih Muslim', 'image': 'media/book2.jpg', 'qty': 1, 'size': '', 'date': 'd', 'status': 'Pending'},
]
real = [{'name': 'تفسير ابن كثير', 'image': 'media/book1.jpg', 'qty': 3}, {'name': 'Sahih Muslim', 'image': 'media/book2.jpg', 'qty': 1}]
rows, changed = rebuild_history([dict(r) for r in cur], real)
check('P4: count-match rows ki galat qty correct hui (1->3)', rows[0]['qty'] == 3 and rows[1]['qty'] == 1 and changed)

# ---------- cancel/return eligibility ----------
def can_cancel(key, status_name):
    import re
    is_ret = bool(re.search(r'return|refund', status_name or '', re.I))
    return bool(key) and key not in ('delivered', 'cancelled') and not is_ret

check('P3: pending par cancel dikhe', can_cancel('pending', 'Pending'))
check('P3: shipped par bhi cancel (delivered tak)', can_cancel('shipped', 'Shipped'))
check('P3: delivered par cancel NAHI (return dikhe)', not can_cancel('delivered', 'Delivered'))
check('P3: cancelled par cancel NAHI', not can_cancel('cancelled', 'Cancelled'))
check('P3: return-status par cancel NAHI', not can_cancel('', 'Return Requested'))

print()
if FAIL:
    print('FAILED:', len(FAIL)); sys.exit(1)
print('ALL VERIFY_V1642 TESTS PASS')
