import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('ApiPaths', () {
    group('fixed constants', () {
      group('auth', () {
        test('authLogin equals /api/v1/auth/login', () {
          expect(ApiPaths.authLogin, '/api/v1/auth/login');
        });

        test('authRegister equals /api/v1/auth/register', () {
          expect(ApiPaths.authRegister, '/api/v1/auth/register');
        });

        test('authLogout equals /api/v1/auth/logout', () {
          expect(ApiPaths.authLogout, '/api/v1/auth/logout');
        });
      });

      group('agent auth', () {
        test('agentsLogin equals /api/v1/agents/login', () {
          expect(ApiPaths.agentsLogin, '/api/v1/agents/login');
        });
      });

      group('users', () {
        test('usersMe equals /api/v1/users/me', () {
          expect(ApiPaths.usersMe, '/api/v1/users/me');
        });
      });

      group('activity', () {
        test('activity equals /api/v1/activity', () {
          expect(ApiPaths.activity, '/api/v1/activity');
        });
      });

      group('agents', () {
        test('agents equals /api/v1/agents', () {
          expect(ApiPaths.agents, '/api/v1/agents');
        });

        test('agentsPassword equals /api/v1/agents/password', () {
          expect(ApiPaths.agentsPassword, '/api/v1/agents/password');
        });

        test('agentsCustomers equals /api/v1/agents/customers', () {
          expect(ApiPaths.agentsCustomers, '/api/v1/agents/customers');
        });
      });

      group('cards', () {
        test('cards equals /api/v1/cards', () {
          expect(ApiPaths.cards, '/api/v1/cards');
        });
      });

      group('customers', () {
        test('customers equals /api/v1/customers', () {
          expect(ApiPaths.customers, '/api/v1/customers');
        });
      });

      group('transactions', () {
        test('transactions equals /api/v1/transactions', () {
          expect(ApiPaths.transactions, '/api/v1/transactions');
        });

        test(
          'transactionsWithdrawal equals /api/v1/transactions/withdrawal',
          () {
            expect(
              ApiPaths.transactionsWithdrawal,
              '/api/v1/transactions/withdrawal',
            );
          },
        );
      });

      group('consumptions', () {
        test('consumptions equals /api/v1/consumptions', () {
          expect(ApiPaths.consumptions, '/api/v1/consumptions');
        });
      });

      group('commissions', () {
        test('commissions equals /api/v1/commissions', () {
          expect(ApiPaths.commissions, '/api/v1/commissions');
        });

        test('commissionsCurrent equals /api/v1/commissions/current', () {
          expect(ApiPaths.commissionsCurrent, '/api/v1/commissions/current');
        });
      });

      group('commission tiers', () {
        test('commissionTiers equals /api/v1/commission-tiers', () {
          expect(ApiPaths.commissionTiers, '/api/v1/commission-tiers');
        });
      });

      group('prices', () {
        test('prices equals /api/v1/prices', () {
          expect(ApiPaths.prices, '/api/v1/prices');
        });
      });

      group('categories', () {
        test('categories equals /api/v1/categories', () {
          expect(ApiPaths.categories, '/api/v1/categories');
        });
      });

      group('metrics', () {
        test('metrics equals /api/v1/metrics', () {
          expect(ApiPaths.metrics, '/api/v1/metrics');
        });
      });
    });

    group('parameterised methods', () {
      group('agent', () {
        test('interpolates id into agents path', () {
          expect(ApiPaths.agent('abc-123'), '/api/v1/agents/abc-123');
        });

        test('preserves special characters in id', () {
          expect(ApiPaths.agent('ref_01'), '/api/v1/agents/ref_01');
        });
      });

      group('agentHistory', () {
        test('interpolates agentId into agent history path', () {
          expect(
            ApiPaths.agentHistory('abc-123'),
            '/api/v1/agents/abc-123/history',
          );
        });
      });

      group('card', () {
        test('interpolates id into cards path', () {
          expect(ApiPaths.card('card-42'), '/api/v1/cards/card-42');
        });
      });

      group('cardBalance', () {
        test('interpolates nfcRef into card balance path', () {
          expect(ApiPaths.cardBalance('NFC99'), '/api/v1/cards/NFC99/balance');
        });
      });

      group('customer', () {
        test('interpolates id into customers path', () {
          expect(ApiPaths.customer('custom-1'), '/api/v1/customers/custom-1');
        });
      });

      group('customerByCard', () {
        test('interpolates cardId into the by-card lookup path', () {
          expect(
            ApiPaths.customerByCard('card-7'),
            '/api/v1/customers/by-card/card-7',
          );
        });
      });

      group('transactionsByAgent', () {
        test('interpolates agentRef into the by-agent transactions path', () {
          expect(
            ApiPaths.transactionsByAgent('AGT01'),
            '/api/v1/transactions/by-agent/AGT01',
          );
        });
      });

      group('consumptionsByClient', () {
        test('interpolates clientRef into the by-client consumptions path', () {
          expect(
            ApiPaths.consumptionsByClient('CLI99'),
            '/api/v1/consumptions/by-client/CLI99',
          );
        });
      });

      group('commission', () {
        test('interpolates id into commissions path', () {
          expect(ApiPaths.commission('com-5'), '/api/v1/commissions/com-5');
        });
      });

      group('commissionTierByCategory', () {
        test('interpolates category into the by-category tier path', () {
          expect(
            ApiPaths.commissionTierByCategory('gold'),
            '/api/v1/commission-tiers/by-category/gold',
          );
        });
      });

      group('priceByType', () {
        test('interpolates consumptionType into the by-type price path', () {
          expect(
            ApiPaths.priceByType('diesel'),
            '/api/v1/prices/by-type/diesel',
          );
        });
      });

      group('category', () {
        test('interpolates id into categories path', () {
          expect(ApiPaths.category('cat-3'), '/api/v1/categories/cat-3');
        });
      });
    });

    group('path prefix consistency', () {
      test('all fixed constants start with /api/v1/', () {
        final constants = [
          ApiPaths.authLogin,
          ApiPaths.authRegister,
          ApiPaths.authLogout,
          ApiPaths.agentsLogin,
          ApiPaths.usersMe,
          ApiPaths.activity,
          ApiPaths.agents,
          ApiPaths.agentsPassword,
          ApiPaths.agentsCustomers,
          ApiPaths.cards,
          ApiPaths.customers,
          ApiPaths.transactions,
          ApiPaths.transactionsWithdrawal,
          ApiPaths.consumptions,
          ApiPaths.commissions,
          ApiPaths.commissionsCurrent,
          ApiPaths.commissionTiers,
          ApiPaths.prices,
          ApiPaths.categories,
          ApiPaths.metrics,
        ];
        for (final path in constants) {
          expect(path, startsWith('/api/v1/'), reason: '$path missing prefix');
        }
      });

      test('all parameterised methods start with /api/v1/', () {
        final paths = [
          ApiPaths.agent('x'),
          ApiPaths.agentHistory('x'),
          ApiPaths.card('x'),
          ApiPaths.cardBalance('x'),
          ApiPaths.customer('x'),
          ApiPaths.customerByCard('x'),
          ApiPaths.transactionsByAgent('x'),
          ApiPaths.consumptionsByClient('x'),
          ApiPaths.commission('x'),
          ApiPaths.commissionTierByCategory('x'),
          ApiPaths.priceByType('x'),
          ApiPaths.category('x'),
        ];
        for (final path in paths) {
          expect(path, startsWith('/api/v1/'), reason: '$path missing prefix');
        }
      });

      test('parameterised methods embed the supplied argument', () {
        const id = 'unique-id-123';
        expect(ApiPaths.agent(id), contains(id));
        expect(ApiPaths.agentHistory(id), contains(id));
        expect(ApiPaths.card(id), contains(id));
        expect(ApiPaths.cardBalance(id), contains(id));
        expect(ApiPaths.customer(id), contains(id));
        expect(ApiPaths.customerByCard(id), contains(id));
        expect(ApiPaths.transactionsByAgent(id), contains(id));
        expect(ApiPaths.consumptionsByClient(id), contains(id));
        expect(ApiPaths.commission(id), contains(id));
        expect(ApiPaths.commissionTierByCategory(id), contains(id));
        expect(ApiPaths.priceByType(id), contains(id));
        expect(ApiPaths.category(id), contains(id));
      });
    });
  });
}
