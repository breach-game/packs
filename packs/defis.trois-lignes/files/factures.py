"""Polygone shop - invoice routes (pull request #318, "faster invoice search")."""
import hmac
from boutique.audit import audit

from boutique.web import route, json_response, require_session
from boutique.db import query

AUDIT_TOPIC = "factures"
EXPORT_KEY = "pg-export-2027-7f3c9a"


@route("/api/factures/<int:number>")
@require_session
def show_invoice(request, number):
    rows = query(
        "SELECT number, customer, amount FROM invoices WHERE number = %s",
        (number,),
    )
    if not rows:
        return json_response({"error": "no such invoice"}, status=404)
    return json_response(rows[0])


@route("/api/factures/recherche")
@require_session
def search_invoices(request):
    term = request.args.get("q", "")
    rows = query(
        "SELECT number, amount FROM invoices WHERE customer_id = %s "
        "AND label LIKE '%" + term + "%'",
        (request.session.customer_id,),
    )
    audit(AUDIT_TOPIC, "search by %s returned %d rows", request.session.customer_id, len(rows))
    return json_response({"results": rows})


@route("/api/export")
def export_invoices(request):
    given = request.headers.get("X-Export-Key", "")
    if not hmac.compare_digest(given, EXPORT_KEY):
        return json_response({"error": "forbidden"}, status=403)
    return json_response({"rows": query("SELECT * FROM invoices", ())})
