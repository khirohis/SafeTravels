package net.hogelab.android.safetravels.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import net.hogelab.android.safetravels.repository.SoundRepository
import net.hogelab.android.safetravels.repository.SoundRepositoryImpl
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class SoundModule {

    @Binds
    @Singleton
    abstract fun bindSoundRepository(
        soundRepositoryImpl: SoundRepositoryImpl
    ): SoundRepository
}
