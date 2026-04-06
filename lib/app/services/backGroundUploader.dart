import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/local/data_base.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';

class BackgroundUploaderService {
	BackgroundUploaderService({
		required this.storageService,
		required this.galleryRepository,
	});

	final StorageLocalService storageService;
	final GalleryRepository galleryRepository;

	StreamSubscription<ConnectivityResult>? _connectivitySubscription;
	bool _isSyncing = false;

	Future<void> init() async {
		await trySyncPendingImages();

		_connectivitySubscription = Connectivity().onConnectivityChanged.listen((
			result,
		) {
			if (result != ConnectivityResult.none) {
				trySyncPendingImages();
			}
		});
	}

	Future<void> trySyncPendingImages() async {
		if (_isSyncing) return;

		final businessId = storageService.readInt('business_id') ?? 0;
		if (businessId == 0) return;

		final connectivityResult = await Connectivity().checkConnectivity();
		if (connectivityResult == ConnectivityResult.none) return;

		_isSyncing = true;

		try {
			final db = await DatabaseHelper().database;
			final pendingImages = await db.query(
				'image',
				where: 'isUploaded = ?',
				whereArgs: [0],
				orderBy: 'id ASC',
			);

			for (final row in pendingImages) {
				final imageId = row['id'] as int;
				final imagePath = row['name'] as String;
				final folderId = row['folder_id'] as int;

				final file = File(imagePath);
				if (!await file.exists()) {
					continue;
				}

				final result = await galleryRepository.uploadImages(
					[file],
					businessId,
					folderId,
				);

				final success = result.fold((_) => false, (_) => true);
				if (success) {
					await db.update(
						'image',
						{'isUploaded': 1},
						where: 'id = ?',
						whereArgs: [imageId],
					);
				}
			}
		} finally {
			_isSyncing = false;
		}
	}

	Future<void> dispose() async {
		await _connectivitySubscription?.cancel();
	}
}
